# 💰 Personal Finance Chatbot

Ứng dụng quản lý tài chính cá nhân có tích hợp chatbot AI (FastAPI + ReactJS + SQL Server).

---

## 🔹 1. TỔNG QUAN DỰ ÁN
- **Backend**: FastAPI (Python 3.10+), OpenAI API, SQL Server  
- **Frontend**: ReactJS (CRA)  
- **Chức năng chính**:
  - Đăng nhập
  - Ghi chú thu nhập, chi tiêu
  - Giao tiếp chatbot để gợi ý và tổng hợp tài chính cá nhân

---

## 🔹 2. CẤU TRÚC DỰ ÁN
```plaintext
personal-finance-chatbot-full/
 ├── backend/
 │   └── app/
 │       ├── auth/         # Xử lý xác thực
 │       ├── crud/         # Xử lý DB
 │       ├── models/       # ORM models
 │       ├── routes/       # Các route: auth, chatbot, budget, income, expense, category
 │       ├── schemas/      # Pydantic schemas
 │       └── main.py       # FastAPI entrypoint
 │       ├── services/     # gpt_service
 │   └── requirements.txt  # Thư viện Python
 │
 ├── frontend/
 │   ├── public/
 │   │   └── index.html
 │   └── src/
 │       ├── components/   # Component giao diện (Navbar, ChatWindow,...)
 │       ├── pages/        # Các trang chính (Login, Chatbot, Dashboard, NotFound)
 │       ├── services/     # Gọi API (api.js)
 │       ├── styles/       # CSS
 │       ├── App.js
 │       ├── routes.js
 │       └── index.js
 │   └── package.json
```

---

## 🔹 3. CHUẨN BỊ MÔI TRƯỜNG

**Yêu cầu:**
- Python: >= 3.10
- Node.js: >= 18.x
- SQL Server (cấu hình trong `.env`)

---

## 🔹 4. KHỞI CHẠY BACKEND (FASTAPI)

**Bước 1**: Tạo môi trường ảo
```bash
cd backend
python -m venv venv
```

**Bước 2**: Kích hoạt môi trường ảo  
- Windows PowerShell:
  ```powershell
  .\venv\Scripts\Activate.ps1
  ```
- CMD:
  ```cmd
  venv\Scripts\activate.bat
  ```
- Linux/Mac:
  ```bash
  source venv/bin/activate
  ```

**Bước 3**: Cài đặt thư viện
```bash
pip install -r requirements.txt
```

**Bước 4**: Khởi chạy server FastAPI
```bash
python -m uvicorn app.main:app --reload --app-dir app
```

---

## 🔹 5. KHỞI CHẠY FRONTEND (REACTJS)

**Bước 1**: Cài đặt thư viện
```bash
cd ../frontend
npm install
```

**Bước 2**: Chạy dự án React
```bash
npm start
```

---

## 🔹 6. KẾT LUẬN
- Giao diện người dùng: [http://localhost:3000](http://localhost:3000)  
- API backend: [http://localhost:8000/docs](http://localhost:8000/docs)  

---

👨‍💻 *Đồ án phát triển bởi nhóm sinh viên …*

A fullstack chatbot for managing personal finance: https://docs.google.com/document/d/1vV0z-gzdKkDILg2RmmL4EyZzg5tmNsnp0-zSTCdmT-A/edit?usp=sharing
