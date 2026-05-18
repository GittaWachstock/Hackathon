from openai import OpenAI
from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2
import json
import re
import os

# =============================
# CONFIG
# =============================

# client = OpenAI(
#     api_key="sk-safeai-c3bccc2f36d07c506a36a64fb6cf6a54f313c825cebf5d6c",
#     base_url="http://your-domain.com/v1"
# )

# response = client.chat.completions.create(
#     model="gpt-4",
#     messages=[{"role": "user", "content": "Hello!"}]
# )
DB_CONFIG = {
    "host": "postgres",
    "port": 5432,
    "database": "sampledb",
    "user": "admin",
    "password": "admin123"
}

MODEL = "gpt-5.4-mini"

FORBIDDEN_KEYWORDS = [
    "DROP",
    "DELETE",
    "UPDATE",
    "ALTER",
    "TRUNCATE",
    "INSERT"
]

# =============================
# FASTAPI
# =============================

app = FastAPI()

# =============================
# OPENAI CLIENT
# =============================

client = OpenAI(
    api_key="sk-safeai-c3bccc2f36d07c506a36a64fb6cf6a54f313c825cebf5d6c",
    base_url="http://192.168.21.157:3001/v1"
)

# =============================
# REQUEST MODEL
# =============================

class QueryRequest(BaseModel):
    prompt: str

# =============================
# DATABASE CONNECTION
# =============================

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

# =============================
# LOAD DATABASE SCHEMA
# =============================

def load_schema():
    conn = get_connection()
    cursor = conn.cursor()

    query = """
    SELECT
        table_name,
        column_name,
        data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    ORDER BY table_name, ordinal_position;
    """

    cursor.execute(query)
    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    schema = {}

    for table, column, dtype in rows:
        schema.setdefault(table, [])
        schema[table].append(f"- {column} ({dtype})")

    output = ""

    for table, columns in schema.items():
        output += f"\nTable {table}:\n"
        output += "\n".join(columns)
        output += "\n"

    return output

# =============================
# BUILD PROMPT
# =============================

def build_prompt(user_input, schema_text):
    return f"""
You are an SQL generation engine.

Your task:
Convert natural language into valid PostgreSQL SQL queries.

Rules:
- Return only JSON
- Never explain
- Never use markdown
- Only SELECT queries are allowed
- Use only provided schema
- Never hallucinate tables or columns

If request is ambiguous return:
{{
  "error": "AMBIGUOUS_REQUEST"
}}

Database schema:

{schema_text}

User Request:
{user_input}
"""

# =============================
# GENERATE SQL
# =============================

def generate_sql(user_input, schema_text):
    prompt = build_prompt(user_input, schema_text)

    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {
                "role": "system",
                "content": """
Return ONLY valid JSON.

Format:
{
  "sql": "SELECT ..."
}
"""
            },
            {
                "role": "user",
                "content": prompt
            }
        ]
    )

    content = response.choices[0].message.content

    print("MODEL RESPONSE:")
    print(content)

    return json.loads(content)
# =============================
# VALIDATE SQL
# =============================

def validate_sql(sql):
    upper_sql = sql.upper()

    for keyword in FORBIDDEN_KEYWORDS:
        if keyword in upper_sql:
            return False

    if not re.match(r"^\s*SELECT", upper_sql):
        return False

    return True

# =============================
# EXECUTE SQL
# =============================

def execute_sql(sql):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(sql)

    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()

    results = []

    for row in rows:
        results.append(dict(zip(columns, row)))

    cursor.close()
    conn.close()

    return results

# =============================
# MAIN AGENT
# =============================

def run_agent(user_input):
    schema_text = load_schema()

    response = generate_sql(user_input, schema_text)

    if "error" in response:
        return response

    sql = response.get("sql")

    if not sql:
        return {
            "error": "NO_SQL_RETURNED"
        }

    if not validate_sql(sql):
        return {
            "error": "INVALID_SQL"
        }

    try:
        results = execute_sql(sql)

        return {
            "sql": sql,
            "results": results
        }

    except Exception as e:
        return {
            "error": str(e),
            "sql": sql
        }

# =============================
# API ROUTES
# =============================

@app.get("/")
def health():
    return {
        "status": "ok"
    }

@app.post("/query")
def query(request: QueryRequest):
    return run_agent(request.prompt)