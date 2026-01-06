# 🔑 Root Password 설정 (Ansible)
- 서버 초기 세팅 시 **root 계정 패스워드 설정**을 수행
- Ansible 변수 `root_password` 값을 사용하여 안전하게 암호화 설정 가능
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# Root Password 설정
# -----------------------------------------------------

# root 패스워드 설정
- name: "Set Root Password"
  user:
    name: root
    password: "{{ root_password | password_hash('sha512') }}"
    shell: /bin/bash

# -----------------------------------------------------
# Root Password 설정 검증
# -----------------------------------------------------

- name: "Assert root password set"
  assert:
    that:
      - root_password is defined
    success_msg: "Good!.. | Root password configured"
    fail_msg: "ERROR!.. | Root password not configured"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Root 계정 패스워드 설정
- Ansible 변수 root_password 값을 사용하여 root 계정 패스워드 설정
- password_hash('sha512') 적용으로 안전하게 암호화
---
### 2️⃣ Root 패스워드 설정 검증
- assert 모듈을 사용하여 root_password 변수가 정의되어 있는지 확인
- 설정 누락 시 플레이북 실패 처리
---

## ✅ 실행 결과 예시
```bash
TASK [Assert root password set]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Root password configured"
}
~
```
---
