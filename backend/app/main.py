from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.routes import auth_routes, chatbot_routes, category_routes, budget_routes, income_routes, expense_routes

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    print("===== All Routes (lifespan startup) =====")
    for route in app.routes:
        print(f"[ROUTE] {route.path} - {route.methods}")

# ✅ chỉ tạo app 1 lần duy nhất
app = FastAPI(lifespan=lifespan)

# ✅ Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Router đăng ký sau khi app được tạo
app.include_router(auth_routes.router)
app.include_router(chatbot_routes.router)
app.include_router(category_routes.router)
app.include_router(budget_routes.router)
app.include_router(income_routes.router)
app.include_router(expense_routes.router)
