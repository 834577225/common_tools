# 代码标准参考

## 通用标准

### 项目结构一致性
- 遵循架构文档中定义的目录结构
- 新文件放到正确的目录
- 遵循已有的模块划分

### 依赖管理
- 新依赖必须有明确理由
- 优先使用项目已有的工具库
- 定期审查和更新依赖

### 环境配置
- 敏感信息使用环境变量
- 不同环境有独立配置
- 配置有合理默认值

---

## TypeScript / JavaScript 标准

### 类型安全
```typescript
// ✅ Good: 明确类型
function getUser(id: string): Promise<User | null> { ... }

// ❌ Bad: any
function getUser(id: any): any { ... }
```

### 异步处理
```typescript
// ✅ Good: async/await
async function fetchData() {
  try {
    const result = await api.get('/data');
    return result;
  } catch (error) {
    logger.error('Failed to fetch data', error);
    throw new AppError('DATA_FETCH_FAILED');
  }
}

// ❌ Bad: 未处理的 Promise
function fetchData() {
  api.get('/data').then(r => r);
}
```

### 导入顺序
```typescript
// 1. 外部依赖
import express from 'express';
import { z } from 'zod';

// 2. 内部模块（绝对路径）
import { UserService } from '@/services/user';
import { logger } from '@/utils/logger';

// 3. 相对路径
import { validateInput } from './validators';
import type { CreateUserDTO } from './types';
```

---

## Python 标准

### 类型注解
```python
# ✅ Good
def get_user(user_id: str) -> User | None:
    ...

# ❌ Bad
def get_user(user_id):
    ...
```

### 错误处理
```python
# ✅ Good: 具体异常
try:
    user = db.get_user(user_id)
except UserNotFoundError:
    raise HTTPException(404, "User not found")
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise HTTPException(500, "Internal error")

# ❌ Bad: 裸 except
try:
    user = db.get_user(user_id)
except:
    pass
```

---

## Go 标准

### 错误处理
```go
// ✅ Good: 检查每个错误
user, err := db.GetUser(userID)
if err != nil {
    return fmt.Errorf("get user %s: %w", userID, err)
}

// ❌ Bad: 忽略错误
user, _ := db.GetUser(userID)
```

### 接口设计
```go
// ✅ Good: 小接口
type UserReader interface {
    GetUser(id string) (*User, error)
}

// ❌ Bad: 胖接口
type UserManager interface {
    GetUser(id string) (*User, error)
    CreateUser(u *User) error
    UpdateUser(u *User) error
    DeleteUser(id string) error
    ListUsers() ([]*User, error)
    SearchUsers(q string) ([]*User, error)
    // ... 20 more methods
}
```

---

## 测试模式

### 单元测试 (AAA Pattern)
```typescript
describe('UserService', () => {
  it('should return user when valid ID provided', async () => {
    // Arrange
    const mockRepo = { findById: vi.fn().mockResolvedValue(mockUser) };
    const service = new UserService(mockRepo);

    // Act
    const result = await service.getUser('user-123');

    // Assert
    expect(result).toEqual(mockUser);
    expect(mockRepo.findById).toHaveBeenCalledWith('user-123');
  });

  it('should throw NotFoundError when user does not exist', async () => {
    // Arrange
    const mockRepo = { findById: vi.fn().mockResolvedValue(null) };
    const service = new UserService(mockRepo);

    // Act & Assert
    await expect(service.getUser('invalid')).rejects.toThrow(NotFoundError);
  });
});
```

### 测试命名
```
should [预期行为] when [条件]

例：
- should return user when valid ID provided
- should throw NotFoundError when user does not exist
- should create order when cart has items
- should reject payment when insufficient balance
```

### 测试覆盖优先级
1. 核心业务逻辑 (必须覆盖)
2. 边界条件和错误路径
3. API 端点（集成测试）
4. 工具函数
5. UI 交互（E2E）
