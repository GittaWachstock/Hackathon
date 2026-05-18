CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100),
    budget INTEGER
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(100),
    team_id INTEGER REFERENCES teams(id),
    salary INTEGER,
    hire_date DATE,
    years_experience INTEGER,
    location VARCHAR(100)
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    team_id INTEGER REFERENCES teams(id),
    status VARCHAR(50),
    deadline DATE,
    priority VARCHAR(50)
);

CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    employee_id INTEGER REFERENCES employees(id),
    project_id INTEGER REFERENCES projects(id),
    status VARCHAR(50),
    estimated_hours INTEGER,
    completed_hours INTEGER
);

INSERT INTO teams (name, manager_name, budget)
VALUES
('AI Team', 'Dana Levi', 500000),
('Backend Team', 'Noam Cohen', 350000),
('Frontend Team', 'Shira Azulay', 250000),
('DevOps Team', 'Eyal Bar', 400000);

INSERT INTO employees
(full_name, role, team_id, salary, hire_date, years_experience, location)
VALUES
('Alice Green', 'Backend Developer', 2, 32000, '2021-04-12', 6, 'Tel Aviv'),
('Bob Miller', 'AI Engineer', 1, 42000, '2020-01-10', 8, 'Haifa'),
('Charlie Stone', 'Frontend Developer', 3, 28000, '2022-08-01', 4, 'Jerusalem'),
('Dana White', 'Data Scientist', 1, 45000, '2019-03-15', 10, 'Tel Aviv'),
('Ethan Black', 'DevOps Engineer', 4, 39000, '2021-09-01', 7, 'Beer Sheva'),
('Fiona Gray', 'QA Engineer', 2, 25000, '2023-01-20', 3, 'Haifa'),
('George King', 'Frontend Developer', 3, 29000, '2022-11-11', 5, 'Tel Aviv'),
('Hila Cohen', 'Product Manager', 1, 50000, '2018-06-17', 12, 'Jerusalem'),
('Ivan Lee', 'Backend Developer', 2, 34000, '2020-02-22', 7, 'Netanya'),
('Julia Fox', 'DevOps Engineer', 4, 41000, '2019-12-01', 9, 'Raanana');

INSERT INTO projects
(name, team_id, status, deadline, priority)
VALUES
('AI Chatbot', 1, 'In Progress', '2026-07-01', 'High'),
('Payment API', 2, 'In Progress', '2026-06-15', 'Critical'),
('Dashboard UI', 3, 'Completed', '2026-05-20', 'Medium'),
('Cloud Migration', 4, 'Planning', '2026-09-10', 'High'),
('Analytics Engine', 1, 'In Progress', '2026-08-01', 'Critical');

INSERT INTO tasks
(title, employee_id, project_id, status, estimated_hours, completed_hours)
VALUES
('Build API endpoints', 1, 2, 'Open', 20, 8),
('Train ML model', 2, 1, 'In Progress', 40, 25),
('Create dashboard page', 3, 3, 'Completed', 15, 15),
('Optimize prompts', 4, 1, 'Open', 10, 3),
('Setup CI/CD', 5, 4, 'In Progress', 30, 18),
('Write integration tests', 6, 2, 'Open', 12, 2),
('Implement navbar', 7, 3, 'Completed', 8, 8),
('Define product roadmap', 8, 5, 'In Progress', 25, 10),
('Refactor auth service', 9, 2, 'Open', 16, 4),
('Deploy monitoring stack', 10, 4, 'In Progress', 22, 12),
('Fine-tune embeddings', 2, 5, 'Open', 35, 9),
('Fix UI responsiveness', 7, 3, 'Completed', 11, 11),
('Database optimization', 1, 2, 'In Progress', 18, 7),
('Kubernetes setup', 5, 4, 'Planning', 45, 0),
('Experiment tracking', 4, 5, 'Open', 14, 5);