# 🕒 Time Zone 설정 (Ansible)

- 시스템 Time Zone을 한국 기준인 **Asia/Seoul** 로 설정한다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# Time zone
# -----------------------------------------------------
# Time zone 설정
- name: "Set Time zone to Asia/Seoul"
  command: timedatectl set-timezone Asia/Seoul

# -----------------------------------------------------
# Time zone 설정 검증
# -----------------------------------------------------
# Time zone 검증
- name: "Assert.. Time zone is Asia/Seoul"
  assert:
    that:
      - "'Asia/Seoul' in lookup('pipe', 'timedatectl')"
    success_msg: "Good!.. | Time zone is set to Asia/Seoul"
    fail_msg: "ERROR!.. | Time zone is NOT Asia/Seoul"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Time Zone 설정
- timedatectl 명령을 사용하여 시스템 Time Zone 변경
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. Time zone is Asia/Seoul]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Time zone is set to Asia/Seoul"
}
~~
```

