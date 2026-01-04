# ⏱ NTP 설정 (Ansible)

- 시스템 시간 동기화를 위해  
  **systemd-timesyncd 기반 NTP 서버를 설정**한다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# NTP 설정
# -----------------------------------------------------
# NTP 서버 설정
- name: "Set NTP server to 0.kr.pool.ntp.org"
  lineinfile:
    path: /etc/systemd/timesyncd.conf
    regexp: '^#?NTP='
    line: 'NTP=0.kr.pool.ntp.org'
    state: present

# systemd-timesyncd 재시작
- name: "Restart systemd-timesyncd"
  systemd:
    name: systemd-timesyncd
    state: restarted

# -----------------------------------------------------
# NTP 설정 검증
# -----------------------------------------------------
# NTP 설정 검증
- name: "Assert.. NTP server is set"
  assert:
    that:
      - "'NTP=0.kr.pool.ntp.org' in lookup('file', '/etc/systemd/timesyncd.conf')"
    success_msg: "Good!.. | NTP server is set to 0.kr.pool.ntp.org"
    fail_msg: "ERROR!.. | NTP server is NOT set"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ NTP 서버 설정
- /etc/systemd/timesyncd.conf 파일에 NTP 서버 지정
- 주석(#NTP=) 상태여도 자동으로 치환
---
### 2️⃣ 시간 동기화 서비스 재시작
- systemd-timesyncd 재시작을 통해 즉시 반영
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. NTP server is set]
ok: [192.168.56.60] => {
    "msg": "Good!.. | NTP server is set to 0.kr.pool.ntp.org"
}
~~
```
