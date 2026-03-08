export const mockUser = {
  name: "Prince Kumar",
  role: "Full Stack Learner",
  avatar: "KK",
  streak: 0,
  totalModules: 12,
  completedModules: 0,
  vivaScore: 0,
  xp: 0,
  level: 1,
};

export const mockRoadmap = {
  title: "Full-Stack React Development",
  modules: [
    {
      id: 1,
      title: "JavaScript Fundamentals",
      status: "active",
      progress: 0,
      duration: "2 weeks",
      topics: ["Variables & Types", "Functions & Closures", "Async/Await", "ES6+ Features"],
    },
    {
      id: 2,
      title: "React Core Concepts",
      status: "locked",
      progress: 0,
      duration: "2 weeks",
      topics: ["JSX & Components", "State & Props", "Hooks", "Context API"],
    },
    {
      id: 3,
      title: "Advanced React Patterns",
      status: "locked",
      progress: 0,
      duration: "1 week",
      topics: ["HOCs", "Render Props", "Custom Hooks", "Compound Components"],
    },
    {
      id: 4,
      title: "State Management",
      status: "locked",
      progress: 0,
      duration: "1 week",
      topics: ["Zustand", "Redux Toolkit", "Jotai", "State Machines"],
    },
    {
      id: 5,
      title: "TypeScript with React",
      status: "locked",
      progress: 0,
      duration: "1 week",
      topics: ["TS Basics", "Generics", "React Types", "Utility Types"],
    },
    {
      id: 6,
      title: "API Integration & Data Fetching",
      status: "locked",
      progress: 0,
      duration: "2 weeks",
      topics: ["REST APIs", "React Query", "SWR", "GraphQL Basics"],
    },
    {
      id: 7,
      title: "Testing & Quality",
      status: "locked",
      progress: 0,
      duration: "1 week",
      topics: ["Jest", "React Testing Library", "E2E with Playwright", "TDD"],
    },
    {
      id: 8,
      title: "Node.js & Express",
      status: "locked",
      progress: 0,
      duration: "2 weeks",
      topics: ["HTTP Server", "Middleware", "Authentication", "REST Design"],
    },
    {
      id: 9,
      title: "Database & ORM",
      status: "locked",
      progress: 0,
      duration: "2 weeks",
      topics: ["PostgreSQL", "Prisma", "Migrations", "Supabase"],
    },
    {
      id: 10,
      title: "Deployment & DevOps",
      status: "locked",
      progress: 0,
      duration: "1 week",
      topics: ["Docker", "CI/CD", "Vercel", "Monitoring"],
    },
    {
      id: 11,
      title: "System Design",
      status: "locked",
      progress: 0,
      duration: "1 week",
      topics: ["Architecture", "Scalability", "Caching", "Message Queues"],
    },
    {
      id: 12,
      title: "Capstone Project",
      status: "locked",
      progress: 0,
      duration: "2 weeks",
      topics: ["Full-Stack App", "Code Review", "Portfolio Piece", "Presentation"],
    },
  ],
};

export const mockActivity = [
  { id: 1, action: "Started Journey", detail: "Welcome to AdaptEd!", time: "Just now", type: "info" as const },
];

export const mockWeeklyProgress = [
  { day: "Mon", hours: 2.5, modules: 1 },
  { day: "Tue", hours: 3.2, modules: 0 },
  { day: "Wed", hours: 1.8, modules: 0 },
  { day: "Thu", hours: 4.1, modules: 1 },
  { day: "Fri", hours: 2.9, modules: 1 },
  { day: "Sat", hours: 5.0, modules: 2 },
  { day: "Sun", hours: 1.5, modules: 0 },
];

export const mockSkillBreakdown = [
  { name: "React", value: 85, fill: "hsl(243, 75%, 59%)" },
  { name: "TypeScript", value: 72, fill: "hsl(199, 89%, 48%)" },
  { name: "Node.js", value: 45, fill: "hsl(152, 69%, 45%)" },
  { name: "Database", value: 30, fill: "hsl(38, 92%, 50%)" },
];

export const mockVivaHistory: any[] = [];
