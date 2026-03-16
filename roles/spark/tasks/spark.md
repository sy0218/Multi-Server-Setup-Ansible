# ☀️ Apache Spark 설치 및 설정 (Ansible) <span style="font-family:monospace;">spark</span>

- Ubuntu 서버에 **Apache Spark 바이너리 설치**
- **지정된 디렉토리 구조로 설치 및 심볼릭 링크 구성**

---

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Spark 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create Spark install directory"
  file:
    path: "{{ spark_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. Spark 다운로드
# -----------------------------------------------------
- name: "Download Spark"
  get_url:
    url: "{{ spark_url }}"
    dest: "/tmp/{{ spark_url | basename }}"
    mode: '0644'
    force: no

# -----------------------------------------------------
# 3. Spark 압축 해제
# -----------------------------------------------------
- name: "Extract Spark"
  unarchive:
    src: "/tmp/{{ spark_url | basename }}"
    dest: "{{ spark_install_dir }}"
    remote_src: yes
    creates: "{{ spark_install_dir }}/{{ (spark_url | basename) | regex_replace('.tgz','') }}"

# -----------------------------------------------------
# 4. Spark 심볼릭 링크 생성
# -----------------------------------------------------
- name: "Create Spark symlink"
  file:
    src: "{{ spark_install_dir }}/{{ (spark_url | basename) | regex_replace('.tgz','') }}"
    dest: "{{ spark_install_dir }}/spark"
    state: link
    force: yes

# -----------------------------------------------------
# 5. Spark 설치 검증
# -----------------------------------------------------
- name: "Check Spark binary"
  stat:
    path: "{{ spark_install_dir }}/spark/bin/spark-submit"
  register: spark_bin_check

- name: "Verify Spark installation"
  assert:
    that:
      - spark_bin_check.stat.exists
    success_msg: "Good!.. | Spark installed successfully ({{ spark_install_dir }}/spark)"
    fail_msg: "ERROR!.. | Spark binary not found. Check download or extraction."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Spark 설치 디렉토리 생성
- Apache Spark 바이너리를 설치할 기본 경로 생성
- `spark_install_dir` 변수 기반 디렉토리 생성
---

### 2️⃣ Spark 바이너리 다운로드
- host.ini에 정의된 `spark_url` 변수 사용
- `/tmp` 디렉토리에 tar.gz 파일 다운로드
- `force: no` 옵션으로 재다운로드 방지
---

### 3️⃣ Spark 압축 해제
- 원격 서버에서 직접 압축 해제 (`remote_src: yes`)
- `creates` 옵션으로 멱등성 보장
---

### 4️⃣ Spark 심볼릭 링크 생성
- 버전 디렉토리 → `spark` 고정 심볼릭 링크 생성
- Spark 버전 업그레이드 시 경로 변경 최소화
---

### 5️⃣ Spark 설치 검증
- `spark/bin/spark-submit` 실행 파일 존재 여부 확인
- 설치 및 심볼릭 링크 정상 여부 `assert`로 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Spark installation]
ok: [apserver] => {
    "msg": "Good!.. | Spark installed successfully (/application/spark)"
}
~
```
---
