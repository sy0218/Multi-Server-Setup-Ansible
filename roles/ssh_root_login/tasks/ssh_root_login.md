# 🔐 SSH Root Login 설정 (Ansible)

- SSH 설정을 통해  
  **root 계정의 SSH 로그인(PermitRootLogin)** 을 허용한다.
- 일반적인 운영 방식인 `/etc/ssh/sshd_config` 파일을 직접 수정한다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# SSH 설정 (Root Login 허용)
# -----------------------------------------------------

- name: "Set SSH PermitRootLogin yes"
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    line: 'PermitRootLogin yes'
    state: present
  notify: Reload sshd

# -----------------------------------------------------
# SSH 설정 검증
# -----------------------------------------------------

- name: "Assert.. PermitRootLogin is enabled"
  assert:
    that:
      - "'PermitRootLogin yes' in lookup('file', '/etc/ssh/sshd_config')"
    success_msg: "Good!.. | SSH root login is enabled (PermitRootLogin yes)"
    fail_msg: "ERROR!.. | SSH root login is NOT enabled"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ SSH Root Login 허용 설정
```yaml
- name: "Set SSH PermitRootLogin yes"
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    line: 'PermitRootLogin yes'
    state: present
    backup: yes
```
- /etc/ssh/sshd_config 파일에서 PermitRootLogin 설정을 관리
- 주석(#PermitRootLogin) 상태여도 자동으로 치환
- 멱등성 보장 (이미 설정되어 있으면 변경 없음)
---
### 2️⃣ SSH 데몬 설정 반영
```yaml
notify: Reload sshd
```
- 설정이 변경된 경우에만 sshd reload 실행
- 불필요한 서비스 재시작 방지
---
### 3️⃣ SSH 설정 검증
```yaml
- name: "Assert.. PermitRootLogin is enabled"
  assert:
    that:
      - "'PermitRootLogin yes' in lookup('file', '/etc/ssh/sshd_config')"
```
- /etc/ssh/sshd_config 파일 기준으로 실제 설정 반영 여부 검증
- 단순 실행 성공이 아닌 결과 기반 검증
---
<br>

## 🧩 handlers/main.yml
```yaml
- name: Reload sshd
  systemd:
    name: sshd
    state: reloaded
```
- SSH 설정 변경 시에만 호출되는 handler
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. PermitRootLogin is enabled]
ok: [192.168.56.60] => {
    "msg": "Good!.. | SSH root login is enabled (PermitRootLogin yes)"
}
~~
```
