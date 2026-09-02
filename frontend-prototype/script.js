'use strict';

/* =========================================================
   TRANSLATIONS
   ========================================================= */
const translations = {
  ru: {
    meta: { title: 'CODESCHOOL — Учись создавать технологии будущего' },
    nav: { home: 'Главная', directions: 'Направления', courses: 'Курсы', children: 'Детям', teachers: 'Преподавателям', parents: 'Родителям', projects: 'Проекты', about: 'О платформе' },
    header: { login: 'Войти', cta: 'Начать обучение' },
    hero: {
      badge: 'Образовательная платформа нового поколения',
      title1: 'Учись создавать', title2: 'технологии будущего',
      subtitle: 'Программирование, робототехника и искусственный интеллект для нового поколения Казахстана.',
      extra: 'От первого алгоритма до собственного IT-продукта.',
      cta1: 'Начать обучение', cta2: 'Стать преподавателем',
      trust1: '6–17 лет', trust2: '3 языка', trust3: 'Практические проекты', trust4: 'AI-наставник'
    },
    path: {
      eyebrow: 'Траектория обучения', title: 'Путь ученика',
      subtitle: 'От первых алгоритмов до собственного стартапа — шесть последовательных ступеней роста.',
      stage1: 'Алгоритмы', stage2: 'Scratch', stage3: 'Python', stage4: 'Web + Robotics', stage5: 'Backend + Mobile', stage6: 'AI + Startup'
    },
    directions: {
      eyebrow: 'Что можно изучать', title: 'Направления обучения',
      subtitle: 'Шесть технологических направлений — от первых строк кода до создания собственных продуктов.',
      card1: { title: 'Programming', tag4: 'Алгоритмы' },
      card2: { title: 'Web Development', tag4: 'Frontend / Backend' },
      card3: { title: 'Robotics', tag2: 'Сенсоры', tag3: 'Электроника', tag4: 'Автоматика' },
      card4: { title: 'Artificial Intelligence', tag3: 'Prompt Engineering', tag4: 'Computer Vision' },
      card5: { title: 'Mobile', tag2: 'Mobile-приложения' },
      card6: { title: 'Game Development', tag2: 'Игровая логика', tag3: '2D-игры', tag4: 'Проекты' }
    },
    courses: { eyebrow: 'Программы обучения', title: 'Популярные программы', subtitle: 'Выберите программу по возрасту и начните путь в технологии уже сегодня.' },
    filter: { all: 'Все', a1: '6–8 лет', a2: '8–10 лет', a3: '10–12 лет', a4: '12–14 лет', a5: '14–17 лет', empty: 'Курсов в этой категории пока нет.' },
    course: {
      scratch: { title: 'Scratch Junior' }, python: { title: 'Python Start' }, robotics: { title: 'Robotics Arduino' },
      web: { title: 'Web Developer' }, ai: { title: 'AI Junior' }, game: { title: 'Game Creator' },
      age: 'Возраст:', years: 'лет', lessons: 'уроков', projects: 'проектов',
      levelBeginner: 'Начальный уровень', levelMiddle: 'Средний уровень', levelAdvanced: 'Продвинутый уровень', more: 'Подробнее'
    },
    children: {
      eyebrow: 'Для детей', title: 'Для детей', lead1: 'Не теория ради теории.',
      lead2: 'Каждый новый навык превращается в настоящий проект.',
      ex1: 'Своя игра', ex2: 'Свой сайт', ex3: 'Собственный робот', ex4: 'Telegram bot', ex5: 'Mobile app', ex6: 'AI project'
    },
    projects: {
      eyebrow: 'Работы учеников', title: 'Проекты учеников', subtitle: 'Реальные проекты, созданные учениками платформы в рамках практических курсов.',
      p1: { title: 'Smart Greenhouse', age: '12 лет', desc: 'Автоматическая теплица с датчиками влажности и температуры.' },
      p2: { title: 'Space Game', age: '9 лет', desc: 'Аркадная игра о космических приключениях с собственной механикой.' },
      p3: { title: 'My First Website', age: '11 лет', desc: 'Персональный сайт-портфолио с адаптивной вёрсткой.' },
      p4: { title: 'AI Chatbot', age: '15 лет', desc: 'Чат-бот с обработкой естественного языка для помощи со школьными задачами.' }
    },
    teacher: {
      eyebrow: 'Teacher Academy', title: 'Teacher Academy',
      subtitle: 'Мы не только обучаем детей. Мы готовим преподавателей, которые смогут обучать новое поколение.',
      step1: 'Изучить Computer Science', step2: 'Освоить методику преподавания', step3: 'Провести практические занятия',
      step4: 'Получить сертификацию', step5: 'Начать преподавать', cta: 'Стать преподавателем'
    },
    aitutor: {
      eyebrow: 'AI-наставник', title: 'AI-наставник',
      desc1: 'ИИ не делает задание вместо ребёнка.', desc2: 'ИИ помогает ребёнку найти решение самостоятельно.',
      q: 'Почему мой цикл не работает?',
      a1: 'Ты правильно используешь <code>for</code>.',
      a2: 'Но посмотри, что находится после слова <code>in</code>.',
      a3: 'Вспомни функцию, которая создаёт последовательность чисел.'
    },
    parents: {
      eyebrow: 'Для родителей', title: 'Для родителей',
      desc: 'Полная прозрачность обучения — вы всегда видите реальный прогресс ребёнка, а не только оценки.',
      progress: 'Прогресс', lessons: 'Уроков', projects: 'Проектов', strength: 'Сильная сторона', strengthValue: 'Алгоритмы',
      nextgoal: 'Следующая цель', nextgoalValue: 'Функции Python'
    },
    dashboard: {
      eyebrow: 'Скоро на платформе', title: 'Личный кабинет ученика',
      subtitle: 'Так будет выглядеть учебная панель — курсы, прогресс, проекты и AI-наставник в одном месте.',
      sidebar1: 'Мои курсы', sidebar2: 'Прогресс', sidebar3: 'Проекты', sidebar4: 'AI Tutor',
      lessonNum: 'Урок 14', lessonName: 'Функции', continue: 'Продолжить обучение'
    },
    stats: { s1: 'языка', s2: 'направлений', s3: 'практических проектов', s4: 'возраст учеников' },
    whyus: {
      eyebrow: 'Наши принципы', title: 'Почему эта система работает',
      w1: 'Практика вместо зубрёжки', w2: 'Проекты вместо обычных контрольных', w3: 'AI-наставник',
      w4: 'Обучение преподавателей', w5: 'Три языка', w6: 'Индивидуальный прогресс', w7: 'Современные технологии'
    },
    philosophy: { line1: 'Ребёнок не должен быть только потребителем технологий.', line2: 'Он должен понимать, как они устроены, и уметь создавать собственные.' },
    finalcta: { title: 'Начни создавать будущее сегодня', cta1: 'Начать обучение', cta2: 'Стать преподавателем', cta3: 'Посмотреть программы' },
    footer: {
      tagline: 'Образовательная IT-платформа для нового поколения Казахстана.',
      platform: 'Платформа', programming: 'Программирование', robotics: 'Робототехника', ai: 'Искусственный интеллект',
      people: 'Люди', teacherAcademy: 'Teacher Academy', about: 'О платформе', contacts: 'Контакты', language: 'Язык',
      rights: 'Все права защищены.', note: 'Прототип интерфейса. Демонстрационные данные.'
    }
  },

  kz: {
    meta: { title: 'CODESCHOOL — Болашақ технологияларын жасауды үйрен' },
    nav: { home: 'Басты бет', directions: 'Бағыттар', courses: 'Курстар', children: 'Балаларға', teachers: 'Мұғалімдерге', parents: 'Ата-аналарға', projects: 'Жобалар', about: 'Платформа туралы' },
    header: { login: 'Кіру', cta: 'Оқуды бастау' },
    hero: {
      badge: 'Жаңа буынға арналған білім беру платформасы',
      title1: 'Болашақ технологияларын', title2: 'жасауды үйрен',
      subtitle: 'Қазақстанның жаңа буыны үшін бағдарламалау, робототехника және жасанды интеллект.',
      extra: 'Алғашқы алгоритмнен өз IT-өніміңізге дейін.',
      cta1: 'Оқуды бастау', cta2: 'Мұғалім болу',
      trust1: '6–17 жас', trust2: '3 тіл', trust3: 'Практикалық жобалар', trust4: 'AI-тәлімгер'
    },
    path: {
      eyebrow: 'Оқу траекториясы', title: 'Оқушының жолы',
      subtitle: 'Алғашқы алгоритмдерден өз стартабыңызға дейін — өсудің алты сатысы.',
      stage1: 'Алгоритмдер', stage2: 'Scratch', stage3: 'Python', stage4: 'Web + Robotics', stage5: 'Backend + Mobile', stage6: 'AI + Startup'
    },
    directions: {
      eyebrow: 'Нені үйренуге болады', title: 'Оқу бағыттары',
      subtitle: 'Алты технологиялық бағыт — кодтың алғашқы жолдарынан өз өнімдеріңізді жасауға дейін.',
      card1: { title: 'Programming', tag4: 'Алгоритмдер' },
      card2: { title: 'Web Development', tag4: 'Frontend / Backend' },
      card3: { title: 'Robotics', tag2: 'Сенсорлар', tag3: 'Электроника', tag4: 'Автоматика' },
      card4: { title: 'Artificial Intelligence', tag3: 'Prompt Engineering', tag4: 'Computer Vision' },
      card5: { title: 'Mobile', tag2: 'Мобильді қосымшалар' },
      card6: { title: 'Game Development', tag2: 'Ойын логикасы', tag3: '2D-ойындар', tag4: 'Жобалар' }
    },
    courses: { eyebrow: 'Оқу бағдарламалары', title: 'Танымал бағдарламалар', subtitle: 'Жасыңызға сай бағдарламаны таңдап, технологиялар әлеміне бүгін бастаңыз.' },
    filter: { all: 'Барлығы', a1: '6–8 жас', a2: '8–10 жас', a3: '10–12 жас', a4: '12–14 жас', a5: '14–17 жас', empty: 'Бұл санатта курстар әзірге жоқ.' },
    course: {
      scratch: { title: 'Scratch Junior' }, python: { title: 'Python Start' }, robotics: { title: 'Robotics Arduino' },
      web: { title: 'Web Developer' }, ai: { title: 'AI Junior' }, game: { title: 'Game Creator' },
      age: 'Жасы:', years: 'жас', lessons: 'сабақ', projects: 'жоба',
      levelBeginner: 'Бастауыш деңгей', levelMiddle: 'Орта деңгей', levelAdvanced: 'Жоғары деңгей', more: 'Толығырақ'
    },
    children: {
      eyebrow: 'Балаларға', title: 'Балаларға', lead1: 'Теория теория үшін емес.',
      lead2: 'Әрбір жаңа дағды нақты жобаға айналады.',
      ex1: 'Өз ойының', ex2: 'Өз сайтың', ex3: 'Меншікті робот', ex4: 'Telegram bot', ex5: 'Mobile app', ex6: 'AI жоба'
    },
    projects: {
      eyebrow: 'Оқушылардың жұмыстары', title: 'Оқушылардың жобалары', subtitle: 'Платформа оқушылары практикалық курстар барысында жасаған нақты жобалар.',
      p1: { title: 'Smart Greenhouse', age: '12 жас', desc: 'Ылғалдылық пен температура сенсорлары бар автоматты жылыжай.' },
      p2: { title: 'Space Game', age: '9 жас', desc: 'Өз механикасы бар ғарыштық шытырман оқиғалар ойыны.' },
      p3: { title: 'My First Website', age: '11 жас', desc: 'Бейімделгіш дизайны бар жеке портфолио-сайт.' },
      p4: { title: 'AI Chatbot', age: '15 жас', desc: 'Мектеп тапсырмаларына көмектесетін табиғи тілді өңдейтін чат-бот.' }
    },
    teacher: {
      eyebrow: 'Teacher Academy', title: 'Teacher Academy',
      subtitle: 'Біз тек балаларды оқытпаймыз. Біз жаңа буынды оқыта алатын мұғалімдерді дайындаймыз.',
      step1: 'Computer Science үйрену', step2: 'Оқыту әдістемесін меңгеру', step3: 'Практикалық сабақтар өткізу',
      step4: 'Сертификат алу', step5: 'Оқытуды бастау', cta: 'Мұғалім болу'
    },
    aitutor: {
      eyebrow: 'AI-тәлімгер', title: 'AI-тәлімгер',
      desc1: 'ИИ тапсырманы бала үшін орындамайды.', desc2: 'ИИ балаға шешімді өз бетінше табуға көмектеседі.',
      q: 'Неге менің циклім жұмыс істемейді?',
      a1: '<code>for</code> сөзін дұрыс қолданып тұрсың.',
      a2: 'Ал <code>in</code> сөзінен кейін не тұрғанына қара.',
      a3: 'Сандар тізбегін жасайтын функцияны есіңе түсір.'
    },
    parents: {
      eyebrow: 'Ата-аналарға', title: 'Ата-аналарға',
      desc: 'Оқудың толық ашықтығы — сіз баланың нақты үлгерімін әрдайым көресіз, тек бағаларды емес.',
      progress: 'Үлгерім', lessons: 'Сабақтар', projects: 'Жобалар', strength: 'Күшті жағы', strengthValue: 'Алгоритмдер',
      nextgoal: 'Келесі мақсат', nextgoalValue: 'Python функциялары'
    },
    dashboard: {
      eyebrow: 'Жақында платформада', title: 'Оқушының жеке кабинеті',
      subtitle: 'Оқу панелі осылай көрінеді — курстар, үлгерім, жобалар және AI-тәлімгер бір жерде.',
      sidebar1: 'Менің курстарым', sidebar2: 'Үлгерім', sidebar3: 'Жобалар', sidebar4: 'AI Tutor',
      lessonNum: '14-сабақ', lessonName: 'Функциялар', continue: 'Оқуды жалғастыру'
    },
    stats: { s1: 'тіл', s2: 'бағыт', s3: 'практикалық жоба', s4: 'оқушылардың жасы' },
    whyus: {
      eyebrow: 'Біздің қағидаттар', title: 'Бұл жүйе неге жұмыс істейді',
      w1: 'Жаттау орнына практика', w2: 'Әдеттегі бақылау жұмыстары орнына жобалар', w3: 'AI-тәлімгер',
      w4: 'Мұғалімдерді оқыту', w5: 'Үш тіл', w6: 'Жеке үлгерім', w7: 'Заманауи технологиялар'
    },
    philosophy: { line1: 'Бала тек технологияны тұтынушы болмауы керек.', line2: 'Ол технологиялардың қалай құрылғанын түсініп, өзінікін жасай білуі керек.' },
    finalcta: { title: 'Болашақты бүгін жасай баста', cta1: 'Оқуды бастау', cta2: 'Мұғалім болу', cta3: 'Бағдарламаларды қарау' },
    footer: {
      tagline: 'Қазақстанның жаңа буынына арналған білім беру IT-платформасы.',
      platform: 'Платформа', programming: 'Бағдарламалау', robotics: 'Робототехника', ai: 'Жасанды интеллект',
      people: 'Адамдар', teacherAcademy: 'Teacher Academy', about: 'Платформа туралы', contacts: 'Байланыс', language: 'Тіл',
      rights: 'Барлық құқықтар қорғалған.', note: 'Интерфейс прототипі. Демо-деректер.'
    }
  },

  en: {
    meta: { title: 'CODESCHOOL — Learn to Build the Technology of Tomorrow' },
    nav: { home: 'Home', directions: 'Directions', courses: 'Courses', children: 'For Kids', teachers: 'For Teachers', parents: 'For Parents', projects: 'Projects', about: 'About' },
    header: { login: 'Log in', cta: 'Start learning' },
    hero: {
      badge: 'A next-generation education platform',
      title1: 'Learn to build', title2: 'the technology of tomorrow',
      subtitle: 'Programming, robotics and artificial intelligence for a new generation of Kazakhstan.',
      extra: 'From your first algorithm to your own IT product.',
      cta1: 'Start learning', cta2: 'Become a teacher',
      trust1: 'Ages 6–17', trust2: '3 languages', trust3: 'Hands-on projects', trust4: 'AI mentor'
    },
    path: {
      eyebrow: 'Learning trajectory', title: 'Student journey',
      subtitle: 'From first algorithms to a real startup — six consecutive stages of growth.',
      stage1: 'Algorithms', stage2: 'Scratch', stage3: 'Python', stage4: 'Web + Robotics', stage5: 'Backend + Mobile', stage6: 'AI + Startup'
    },
    directions: {
      eyebrow: 'What you can learn', title: 'Learning directions',
      subtitle: 'Six technology tracks — from the first lines of code to building your own products.',
      card1: { title: 'Programming', tag4: 'Algorithms' },
      card2: { title: 'Web Development', tag4: 'Frontend / Backend' },
      card3: { title: 'Robotics', tag2: 'Sensors', tag3: 'Electronics', tag4: 'Automation' },
      card4: { title: 'Artificial Intelligence', tag3: 'Prompt Engineering', tag4: 'Computer Vision' },
      card5: { title: 'Mobile', tag2: 'Mobile apps' },
      card6: { title: 'Game Development', tag2: 'Game logic', tag3: '2D games', tag4: 'Projects' }
    },
    courses: { eyebrow: 'Learning programs', title: 'Popular programs', subtitle: 'Choose a program by age and start your journey into technology today.' },
    filter: { all: 'All', a1: 'Ages 6–8', a2: 'Ages 8–10', a3: 'Ages 10–12', a4: 'Ages 12–14', a5: 'Ages 14–17', empty: 'No courses in this category yet.' },
    course: {
      scratch: { title: 'Scratch Junior' }, python: { title: 'Python Start' }, robotics: { title: 'Robotics Arduino' },
      web: { title: 'Web Developer' }, ai: { title: 'AI Junior' }, game: { title: 'Game Creator' },
      age: 'Age:', years: 'years', lessons: 'lessons', projects: 'projects',
      levelBeginner: 'Beginner level', levelMiddle: 'Intermediate level', levelAdvanced: 'Advanced level', more: 'Learn more'
    },
    children: {
      eyebrow: 'For kids', title: 'For kids', lead1: 'Not theory for the sake of theory.',
      lead2: 'Every new skill turns into a real project.',
      ex1: 'Your own game', ex2: 'Your own website', ex3: 'Your own robot', ex4: 'Telegram bot', ex5: 'Mobile app', ex6: 'AI project'
    },
    projects: {
      eyebrow: "Student work", title: 'Student projects', subtitle: 'Real projects built by students during hands-on courses.',
      p1: { title: 'Smart Greenhouse', age: 'age 12', desc: 'An automated greenhouse with humidity and temperature sensors.' },
      p2: { title: 'Space Game', age: 'age 9', desc: 'An arcade game about space adventures with custom-built mechanics.' },
      p3: { title: 'My First Website', age: 'age 11', desc: 'A personal portfolio website with responsive layout.' },
      p4: { title: 'AI Chatbot', age: 'age 15', desc: 'A natural-language chatbot that helps with school assignments.' }
    },
    teacher: {
      eyebrow: 'Teacher Academy', title: 'Teacher Academy',
      subtitle: "We don't just teach kids. We train teachers who can educate the next generation.",
      step1: 'Study Computer Science', step2: 'Master teaching methodology', step3: 'Run hands-on classes',
      step4: 'Get certified', step5: 'Start teaching', cta: 'Become a teacher'
    },
    aitutor: {
      eyebrow: 'AI mentor', title: 'AI mentor',
      desc1: "AI doesn't do the assignment for the child.", desc2: 'AI helps the child find the solution on their own.',
      q: "Why isn't my loop working?",
      a1: "You're using <code>for</code> correctly.",
      a2: 'But look at what comes after the word <code>in</code>.',
      a3: 'Remember the function that creates a sequence of numbers.'
    },
    parents: {
      eyebrow: 'For parents', title: 'For parents',
      desc: 'Full learning transparency — you always see real progress, not just grades.',
      progress: 'Progress', lessons: 'Lessons', projects: 'Projects', strength: 'Strong point', strengthValue: 'Algorithms',
      nextgoal: 'Next goal', nextgoalValue: 'Python functions'
    },
    dashboard: {
      eyebrow: 'Coming to the platform', title: 'Student dashboard',
      subtitle: "This is what the learning panel will look like — courses, progress, projects and the AI mentor in one place.",
      sidebar1: 'My courses', sidebar2: 'Progress', sidebar3: 'Projects', sidebar4: 'AI Tutor',
      lessonNum: 'Lesson 14', lessonName: 'Functions', continue: 'Continue learning'
    },
    stats: { s1: 'languages', s2: 'directions', s3: 'hands-on projects', s4: 'student age range' },
    whyus: {
      eyebrow: 'Our principles', title: 'Why this system works',
      w1: 'Practice instead of memorizing', w2: 'Projects instead of ordinary tests', w3: 'AI mentor',
      w4: 'Teacher training', w5: 'Three languages', w6: 'Individual progress', w7: 'Modern technology'
    },
    philosophy: { line1: 'A child should not be only a consumer of technology.', line2: 'They should understand how it works and be able to create their own.' },
    finalcta: { title: 'Start building the future today', cta1: 'Start learning', cta2: 'Become a teacher', cta3: 'View programs' },
    footer: {
      tagline: 'An educational IT platform for the new generation of Kazakhstan.',
      platform: 'Platform', programming: 'Programming', robotics: 'Robotics', ai: 'Artificial Intelligence',
      people: 'People', teacherAcademy: 'Teacher Academy', about: 'About', contacts: 'Contacts', language: 'Language',
      rights: 'All rights reserved.', note: 'Interface prototype. Demo data.'
    }
  }
};

/* =========================================================
   STATE
   ========================================================= */
const LANG_KEY = 'codeschool-lang';
const THEME_KEY = 'codeschool-theme';
let currentLang = localStorage.getItem(LANG_KEY) || 'ru';

/* =========================================================
   i18n
   ========================================================= */
function getTranslation(lang, key) {
  return key.split('.').reduce((obj, part) => (obj && obj[part] !== undefined ? obj[part] : undefined), translations[lang]);
}

function setLanguage(lang) {
  if (!translations[lang]) lang = 'ru';
  currentLang = lang;
  localStorage.setItem(LANG_KEY, lang);
  document.documentElement.lang = lang;

  document.querySelectorAll('[data-i18n]').forEach((el) => {
    const key = el.getAttribute('data-i18n');
    const value = getTranslation(lang, key);
    if (value !== undefined) el.innerHTML = value;
  });

  document.querySelectorAll('.lang-btn').forEach((btn) => {
    const isActive = btn.dataset.lang === lang;
    btn.classList.toggle('active', isActive);
    btn.setAttribute('aria-pressed', String(isActive));
  });

  const title = getTranslation(lang, 'meta.title');
  if (title) document.title = title;
}

/* =========================================================
   THEME
   ========================================================= */
function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem(THEME_KEY, theme);
  const toggle = document.getElementById('theme-toggle');
  if (toggle) toggle.setAttribute('aria-pressed', String(theme === 'light'));
}

function initTheme() {
  const saved = localStorage.getItem(THEME_KEY);
  setTheme(saved === 'light' ? 'light' : 'dark');
}

/* =========================================================
   HEADER SCROLL STATE
   ========================================================= */
function initHeaderScroll() {
  const header = document.getElementById('site-header');
  if (!header) return;
  const update = () => header.classList.toggle('scrolled', window.scrollY > 12);
  update();
  window.addEventListener('scroll', update, { passive: true });
}

/* =========================================================
   MOBILE DRAWER
   ========================================================= */
function initMobileMenu() {
  const btn = document.getElementById('mobile-menu-btn');
  const drawer = document.getElementById('mobile-drawer');
  const closeBtn = document.getElementById('mobile-drawer-close');
  const backdrop = document.getElementById('mobile-drawer-backdrop');
  if (!btn || !drawer) return;

  const open = () => {
    drawer.classList.add('open');
    backdrop.classList.add('open');
    btn.setAttribute('aria-expanded', 'true');
    document.body.style.overflow = 'hidden';
  };
  const close = () => {
    drawer.classList.remove('open');
    backdrop.classList.remove('open');
    btn.setAttribute('aria-expanded', 'false');
    document.body.style.overflow = '';
  };

  btn.addEventListener('click', open);
  closeBtn.addEventListener('click', close);
  backdrop.addEventListener('click', close);
  drawer.querySelectorAll('.mobile-nav-link, .mobile-drawer-actions a').forEach((link) => {
    link.addEventListener('click', close);
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && drawer.classList.contains('open')) close();
  });
}

/* =========================================================
   LANGUAGE + THEME CONTROLS
   ========================================================= */
function initControls() {
  document.querySelectorAll('.lang-btn').forEach((btn) => {
    btn.addEventListener('click', () => setLanguage(btn.dataset.lang));
  });

  const themeToggle = document.getElementById('theme-toggle');
  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const current = document.documentElement.getAttribute('data-theme') || 'dark';
      setTheme(current === 'dark' ? 'light' : 'dark');
    });
  }
}

/* =========================================================
   COURSE FILTERING
   ========================================================= */
function initCourseFilter() {
  const tabs = document.querySelectorAll('.filter-tab');
  const cards = document.querySelectorAll('.course-card');
  const emptyMsg = document.getElementById('filter-empty');
  if (!tabs.length) return;

  tabs.forEach((tab) => {
    tab.addEventListener('click', () => {
      tabs.forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');

      const filter = tab.dataset.filter;
      let visibleCount = 0;
      cards.forEach((card) => {
        const show = filter === 'all' || card.dataset.age === filter;
        card.classList.toggle('filtered-out', !show);
        if (show) visibleCount++;
      });
      if (emptyMsg) emptyMsg.hidden = visibleCount !== 0;
    });
  });
}

/* =========================================================
   ACTIVE NAV LINK ON SCROLL
   ========================================================= */
function initActiveNav() {
  const navLinks = document.querySelectorAll('.main-nav .nav-link');
  if (!navLinks.length) return;

  const sections = Array.from(navLinks)
    .map((link) => document.querySelector(link.getAttribute('href')))
    .filter(Boolean);

  if (!('IntersectionObserver' in window) || !sections.length) return;

  const setActive = (id) => {
    navLinks.forEach((link) => {
      link.classList.toggle('active', link.getAttribute('href') === `#${id}`);
    });
  };

  const markerY = () => window.innerHeight * 0.48;

  const updateActive = () => {
    const y = markerY();
    let current = sections[0];
    for (const section of sections) {
      const rect = section.getBoundingClientRect();
      if (rect.top <= y) current = section;
    }
    setActive(current.id);
  };

  const observer = new IntersectionObserver(updateActive, { rootMargin: '-45% 0px -50% 0px', threshold: 0 });
  sections.forEach((section) => observer.observe(section));
  updateActive();
}

/* =========================================================
   SCROLL REVEAL ANIMATIONS
   ========================================================= */
function initRevealAnimations() {
  const items = document.querySelectorAll('.reveal');
  if (!items.length) return;

  if (!('IntersectionObserver' in window)) {
    items.forEach((el) => el.classList.add('is-visible'));
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.15, rootMargin: '0px 0px -60px 0px' }
  );

  items.forEach((el) => observer.observe(el));
}

/* =========================================================
   ANIMATED COUNTERS
   ========================================================= */
function animateCounter(el) {
  const target = parseInt(el.dataset.count, 10);
  const suffix = el.dataset.suffix || '';
  const duration = 1400;
  const start = performance.now();

  function tick(now) {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    const value = Math.round(target * eased);
    el.textContent = value + suffix;
    if (progress < 1) requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
}

function initCounters() {
  const staticEls = document.querySelectorAll('.stat-number[data-static]');
  staticEls.forEach((el) => { el.textContent = el.dataset.static; });

  const counters = document.querySelectorAll('.stat-number[data-count]');
  if (!counters.length) return;

  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (!('IntersectionObserver' in window) || prefersReduced) {
    counters.forEach((el) => { el.textContent = el.dataset.count + (el.dataset.suffix || ''); });
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.5 }
  );

  counters.forEach((el) => observer.observe(el));
}

/* =========================================================
   FOOTER YEAR
   ========================================================= */
function initFooterYear() {
  const el = document.getElementById('footer-year');
  if (el) el.textContent = new Date().getFullYear();
}

/* =========================================================
   INIT
   ========================================================= */
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  setLanguage(currentLang);
  initControls();
  initHeaderScroll();
  initMobileMenu();
  initCourseFilter();
  initActiveNav();
  initRevealAnimations();
  initCounters();
  initFooterYear();

  if (window.lucide && typeof window.lucide.createIcons === 'function') {
    window.lucide.createIcons();
  }
});
