# 📂 Open Files 설정 (nofile)

- root 계정이 동시에 열 수 있는 파일 수 제한을 증가시킨다.
- 시스템 기본 제한으로 인한 서비스 장애를 방지하기 위한 설정이다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# Open files 설정 (nofile)
# -----------------------------------------------------

- name: "Set open files limit for root"
  lineinfile:
    path: /etc/security/limits.conf
    regexp: '^root\s+-\s+nofile'
    line: 'root - nofile 65536'
    state: present

# -----------------------------------------------------
# Open files 설정 검증
# -----------------------------------------------------

- name: "Assert.. open files limit is set for root"
  assert:
    that:
      - "'root - nofile 65536' in lookup('file', '/etc/security/limits.conf')"
    success_msg: "Good!.. | Open files limit for root is set to 65536"
    fail_msg: "ERROR!.. | Open files limit for root is NOT set"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Open Files 제한 설정
- /etc/security/limits.conf 파일을 직접 수정
- root 계정의 nofile 제한을 65536 으로 설정
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. open files limit is set for root]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Open files limit for root is set to 65536"
}
~~
```
