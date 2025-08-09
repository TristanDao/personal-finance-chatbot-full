# password_hash.py
from passlib.context import CryptContext
# Define the password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash a password using bcrypt."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)

# def get_password_hash(password: str) -> str:
#     """Get the hashed password."""
#     return hash_password(password)
