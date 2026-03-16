# 🐝 Apache Hive 설치 및 설정 (Ansible)

- Ubuntu 서버에 **Apache Hive 바이너리 설치**  
- **지정된 디렉토리 구조로 설치 및 심볼릭 링크 구성**

---

<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Hive 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create Hive install directory"
  file:
    path: "{{ hive_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. Hive 다운로드
# -----------------------------------------------------
- name: "Download Hive"
  get_url:
    url: "{{ hive_url }}"
    dest: "/tmp/{{ hive_url | basename }}"
    mode: '0644'
    force: no

# -----------------------------------------------------
# 3. Hive 압축 해제
# -----------------------------------------------------
- name: "Extract Hive"
  unarchive:
    src: "/tmp/{{ hive_url | basename }}"
    dest: "{{ hive_install_dir }}"
    remote_src: yes
    creates: "{{ hive_install_dir }}/{{ (hive_url | basename) | regex_replace('.tar.gz','') }}"

# -----------------------------------------------------
# 4. Hive 심볼릭 링크 생성
# -----------------------------------------------------
- name: "Create Hive symlink"
  file:
    src: "{{ hive_install_dir }}/{{ (hive_url | basename) | regex_replace('.tar.gz','') }}"
    dest: "{{ hive_install_dir }}/hive"
    state: link
    force: yes

# -----------------------------------------------------
# 5. Hive 설치 검증
# -----------------------------------------------------
- name: "Check Hive binary"
  stat:
    path: "{{ hive_install_dir }}/hive/bin/hive"
  register: hive_bin_check

- name: "Verify Hive installation"
  assert:
    that:
      - hive_bin_check.stat.exists
    success_msg: "Good!.. | Hive installed successfully ({{ hive_install_dir }}/hive)"
    fail_msg: "ERROR!.. | Hive binary not found. Check download or extraction."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Hive 설치 디렉토리 생성
- Apache Hive 바이너리를 설치할 기본 경로 생성  
- `hive_install_dir` 변수 기반 디렉토리 생성  

---

### 2️⃣ Hive 바이너리 다운로드
- `host.ini`에 정의된 `hive_url` 변수 사용  
- `/tmp` 디렉토리에 tar.gz 파일 다운로드  
- `force: no` 옵션으로 재다운로드 방지  

---

### 3️⃣ Hive 압축 해제
- 원격 서버에서 직접 압축 해제 (`remote_src: yes`)  
- `creates` 옵션으로 멱등성 보장  

---

### 4️⃣ Hive 심볼릭 링크 생성
- 버전 디렉토리 → `hive` 고정 심볼릭 링크 생성  
- Hive 버전 업그레이드 시 경로 변경 최소화  

---

### 5️⃣ Hive 설치 검증
- `hive/bin/hive` 실행 파일 존재 여부 확인  
- 설치 및 심볼릭 링크 정상 여부 `assert`로 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Hive installation]
ok: [apserver] => {
    "msg": "Good!.. | Hive installed successfully (/application/hive)"
}
~
```
---
