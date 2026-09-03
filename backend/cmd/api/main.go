package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/admin"
	"codeschool/backend/internal/assignments"
	"codeschool/backend/internal/auth"
	"codeschool/backend/internal/config"
	"codeschool/backend/internal/courses"
	"codeschool/backend/internal/database"
	"codeschool/backend/internal/enrollments"
	"codeschool/backend/internal/groups"
	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/lessons"
	"codeschool/backend/internal/levels"
	"codeschool/backend/internal/middleware"
	"codeschool/backend/internal/modules"
	"codeschool/backend/internal/parents"
	"codeschool/backend/internal/programs"
	"codeschool/backend/internal/progress"
	"codeschool/backend/internal/quizzes"
	"codeschool/backend/internal/runs"
	"codeschool/backend/internal/submissions"
	"codeschool/backend/internal/users"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("fatal: %v", err)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	pool, err := database.NewPool(cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()
	log.Println("database connected")

	if cfg.IsProduction() {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()
	router.Use(gin.Logger(), gin.Recovery())
	router.Use(middleware.CORS(cfg.CORSAllowedOrigins))

	httpx.RegisterHealthRoutes(router, func(ctx context.Context) error {
		return database.Ready(ctx, pool)
	})

	// Wire domains: repository -> service -> handler, then routes.
	// levels and modules/lessons services are constructed first since
	// programs and courses compose them.
	levelsRepo := levels.NewRepository(pool)
	levelsService := levels.NewService(levelsRepo)
	levelsHandler := levels.NewHandler(levelsService)

	programsRepo := programs.NewRepository(pool)
	programsService := programs.NewService(programsRepo)
	programsHandler := programs.NewHandler(programsService, levelsService)

	modulesRepo := modules.NewRepository(pool)
	modulesService := modules.NewService(modulesRepo)
	modulesHandler := modules.NewHandler(modulesService)

	lessonsRepo := lessons.NewRepository(pool)
	lessonsService := lessons.NewService(lessonsRepo)
	lessonsHandler := lessons.NewHandler(lessonsService)

	coursesRepo := courses.NewRepository(pool)
	coursesService := courses.NewService(coursesRepo, modulesService, lessonsService)
	coursesHandler := courses.NewHandler(coursesService)

	// Users + auth.
	usersRepo := users.NewRepository(pool)
	usersService := users.NewService(usersRepo)
	usersHandler := users.NewHandler(usersService)

	tokenManager := auth.NewTokenManager(cfg.JWTSecret, cfg.JWTAccessTTL, cfg.JWTRefreshTTL)
	authRepo := auth.NewRepository(pool)
	authService := auth.NewService(usersService, authRepo, tokenManager)
	authHandler := auth.NewHandler(authService, cfg.IsProduction())
	authMiddleware := auth.Middleware(tokenManager, usersService)

	// Student flow: enrollments -> assignments -> submissions -> progress
	// (constructed in dependency order).
	enrollmentsRepo := enrollments.NewRepository(pool)
	enrollmentsService := enrollments.NewService(enrollmentsRepo, coursesRepo)
	enrollmentsHandler := enrollments.NewHandler(enrollmentsService)

	assignmentsRepo := assignments.NewRepository(pool)
	assignmentsService := assignments.NewService(assignmentsRepo, lessonsService, enrollmentsService)
	assignmentsHandler := assignments.NewHandler(assignmentsService)

	submissionsRepo := submissions.NewRepository(pool)
	submissionsService := submissions.NewService(submissionsRepo, assignmentsService, enrollmentsService)
	submissionsHandler := submissions.NewHandler(submissionsService)

	// Quiz engine: authoring (admin) + attempts/scoring (student) + read views.
	quizzesRepo := quizzes.NewRepository(pool)
	quizzesService := quizzes.NewService(quizzesRepo, enrollmentsService)
	quizzesAdminService := quizzes.NewAdminService(quizzesRepo)
	quizzesHandler := quizzes.NewHandler(quizzesService)
	quizzesAdminHandler := quizzes.NewAdminHandler(quizzesAdminService)

	// Code runner: forwards code to the sandboxed `runner` service, records
	// history, serves visible tests, auto-grades against hidden tests. The
	// runner is optional — if RUNNER_URL is unset the endpoints return 503.
	runsRepo := runs.NewRepository(pool)
	runnerClient := runs.NewRunnerClient(cfg.RunnerURL)
	runsService := runs.NewService(runsRepo, runnerClient, assignmentsService, enrollmentsService, submissionsService)
	runsAdminService := runs.NewAdminService(runsRepo, assignmentsService)
	runsHandler := runs.NewHandler(runsService)
	runsAdminHandler := runs.NewAdminHandler(runsAdminService)
	if cfg.RunnerURL == "" {
		log.Println("code runner disabled (RUNNER_URL not set)")
	} else {
		log.Printf("code runner enabled: %s", cfg.RunnerURL)
	}

	progressRepo := progress.NewRepository(pool)
	progressService := progress.NewService(
		progressRepo, lessonsService, enrollmentsService, enrollmentsService,
		assignmentsService, submissionsService, quizzesService, runsService,
	)
	progressHandler := progress.NewHandler(progressService)

	// Teacher flow: groups + submission review (reuses submissionsService).
	groupsRepo := groups.NewRepository(pool)
	groupsService := groups.NewService(groupsRepo, submissionsService)
	groupsHandler := groups.NewHandler(groupsService)

	// Parent flow: read-only view of linked children.
	parentsRepo := parents.NewRepository(pool)
	parentsService := parents.NewService(parentsRepo)
	parentsHandler := parents.NewHandler(parentsService)

	// Admin panel: full CRUD over users / catalog / groups / links + audit.
	adminRepo := admin.NewRepository(pool)
	adminService := admin.NewService(adminRepo, groupsRepo)
	adminHandler := admin.NewHandler(adminService)

	apiV1 := router.Group("/api/v1")
	programs.RegisterRoutes(apiV1, programsHandler)
	levels.RegisterRoutes(apiV1, levelsHandler)
	courses.RegisterRoutes(apiV1, coursesHandler)
	modules.RegisterRoutes(apiV1, modulesHandler)
	lessons.RegisterRoutes(apiV1, lessonsHandler)

	// Public auth endpoints (register/login/refresh/logout).
	auth.RegisterRoutes(apiV1, authHandler)

	// Protected endpoints — require a valid access token.
	protected := apiV1.Group("")
	protected.Use(authMiddleware)
	users.RegisterRoutes(protected, usersHandler)
	registerRolePings(protected)

	// Student-only endpoints — valid access token + role == "student".
	student := protected.Group("")
	student.Use(auth.RequireRole("student"))
	enrollments.RegisterRoutes(student, enrollmentsHandler)
	assignments.RegisterRoutes(student, assignmentsHandler)
	submissions.RegisterRoutes(student, submissionsHandler)
	progress.RegisterRoutes(student, progressHandler)
	quizzes.RegisterStudentRoutes(student, quizzesHandler)
	runs.RegisterStudentRoutes(student, runsHandler)

	// Teacher-only endpoints — valid access token + role == "teacher".
	teacher := protected.Group("")
	teacher.Use(auth.RequireRole("teacher"))
	groups.RegisterRoutes(teacher, groupsHandler)
	quizzes.RegisterTeacherRoutes(teacher, quizzesHandler)

	// Parent-only endpoints — valid access token + role == "parent". Every
	// route is read-only (GET).
	parent := protected.Group("")
	parent.Use(auth.RequireRole("parent"))
	parents.RegisterRoutes(parent, parentsHandler)

	// Admin-only endpoints — valid access token + role == "admin".
	adminGroup := protected.Group("")
	adminGroup.Use(auth.RequireRole("admin"))
	admin.RegisterRoutes(adminGroup, adminHandler)
	quizzes.RegisterAdminRoutes(adminGroup, quizzesAdminHandler)
	runs.RegisterAdminRoutes(adminGroup, runsAdminHandler)

	srv := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           router,
		ReadHeaderTimeout: 5 * time.Second,
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	serveErr := make(chan error, 1)
	go func() {
		log.Printf("server listening on :%s", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serveErr <- err
		}
		close(serveErr)
	}()

	select {
	case <-ctx.Done():
		log.Println("shutdown signal received")
	case err := <-serveErr:
		if err != nil {
			return err
		}
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		return err
	}
	log.Println("server stopped cleanly")
	return nil
}

// registerRolePings mounts tiny per-role endpoints used to verify role
// authorization end-to-end (e.g. a student token must be rejected from
// /admin/ping). They carry no business data.
func registerRolePings(rg *gin.RouterGroup) {
	pong := func(role string) gin.HandlerFunc {
		return func(c *gin.Context) {
			httpx.OK(c, gin.H{"message": role + " access ok"})
		}
	}
	rg.GET("/student/ping", auth.RequireRole("student"), pong("student"))
	rg.GET("/teacher/ping", auth.RequireRole("teacher"), pong("teacher"))
	rg.GET("/parent/ping", auth.RequireRole("parent"), pong("parent"))
	rg.GET("/admin/ping", auth.RequireRole("admin"), pong("admin"))
}
