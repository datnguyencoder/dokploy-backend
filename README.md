# 🏥 Laboratory Information System (LIS)

### Hệ Thống Quản Lý Phòng Xét Nghiệm Y Khoa

> **Kiến trúc Microservices hoàn chỉnh** — Xây dựng bằng Java 21, Spring Boot 3.5, Spring Cloud 2025, Apache Kafka và Docker
> Mô phỏng quy trình vận hành thực tế của một phòng xét nghiệm máu (Huyết học)

![Java](https://img.shields.io/badge/Java-21-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.5.6-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)
![Spring Cloud](https://img.shields.io/badge/Spring_Cloud-2025.0.0-6DB33F?style=for-the-badge&logo=spring&logoColor=white)
![Kafka](https://img.shields.io/badge/Apache_Kafka-7.5-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-LTS-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Latest-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Latest-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-Dashboard-F46800?style=for-the-badge&logo=grafana&logoColor=white)

---

## 📖 Mục Lục

- [Tổng Quan Dự Án](#-tổng-quan-dự-án)
- [Kiến Trúc Hệ Thống](#-kiến-trúc-hệ-thống)
- [Luồng Hoạt Động (Flow)](#-luồng-hoạt-động-flow)
- [Danh Sách Microservices](#-danh-sách-microservices)
- [Chức Năng Chi Tiết](#-chức-năng-chi-tiết)
- [Tech Stack](#-tech-stack--điểm-nổi-bật)
- [Cấu Trúc Thư Mục](#-cấu-trúc-thư-mục)
- [Cài Đặt và Triển Khai](#-cài-đặt-và-triển-khai)
- [API Documentation](#-api-documentation)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring và Observability](#-monitoring-và-observability)
- [Đội Ngũ Phát Triển](#-đội-ngũ-phát-triển)

---

## 🎯 Tổng Quan Dự Án

**Laboratory Information System (LIS)** là một hệ thống quản lý phòng xét nghiệm y khoa được thiết kế theo kiến trúc **Microservices**, mô phỏng đầy đủ quy trình vận hành thực tế từ khâu **tiếp nhận bệnh nhân → tạo y lệnh xét nghiệm → phân tích mẫu máu trên máy huyết học → trả kết quả HL7 → giám sát toàn bộ hoạt động**.

### 🔑 Điểm Nổi Bật Cốt Lõi

| # | Điểm Nổi Bật | Mô Tả |
|---|-------------|-------|
| 1 | **Mô phỏng máy xét nghiệm huyết học** | Sinh dữ liệu xét nghiệm máu (CBC) thực tế, đóng gói theo chuẩn **HL7 v2.5.1** |
| 2 | **eKYC với VNPT** | Tích hợp API VNPT để xác minh danh tính qua CCCD/CMND (OCR + Classify) |
| 3 | **Event-Driven Architecture** | Các service giao tiếp bất đồng bộ qua Apache Kafka với 3 partitions |
| 4 | **Audit Trail tự động** | AOP-based logging tự động ghi nhận mọi thao tác CUD trên toàn hệ thống |
| 5 | **Multi-Database Strategy** | Polyglot Persistence: MySQL + PostgreSQL + MongoDB cho từng bounded context |
| 6 | **OAuth2 + Social Login** | Hỗ trợ đăng nhập qua Google, Facebook; JWT Token với refresh flow đầy đủ |
| 7 | **Full Observability Stack** | Prometheus + Grafana + Spring Boot Actuator + Micrometer tracing |
| 8 | **CI/CD Automation** | GitHub Actions tự động build và push 9 Docker images lên Docker Hub |
| 9 | **Centralized Swagger** | API Gateway aggregate Swagger UI từ tất cả services vào 1 endpoint duy nhất |

---

## 🏗 Kiến Trúc Hệ Thống

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                                     CLIENT (Frontend)                                    │
└──────────────────────────────────────┬───────────────────────────────────────────────────┘
                                       │ HTTP/REST
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                           🌐 API GATEWAY (Spring Cloud Gateway)                          │
│                              Port: 6789 | WebFlux (Reactive)                             │
│                    ┌───────────────────────────────────────────────┐                      │
│                    │  JWT Token Introspection (Global Filter)      │                      │
│                    │  Route-based Load Balancing (lb://)           │                      │
│                    │  Centralized Swagger Aggregation              │                      │
│                    │  Whitelist & Public Endpoint Management       │                      │
│                    └───────────────────────────────────────────────┘                      │
└───────────┬──────────┬──────────┬──────────┬──────────┬──────────┬───────────────────────┘
            │          │          │          │          │          │
            ▼          ▼          ▼          ▼          ▼          ▼
┌─────────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐
│ IAM Service │ │ Patient  │ │TestOrder │ │Warehouse │ │Instrument│ │ Monitoring   │
│   :8081     │ │ Service  │ │ Service  │ │ Service  │ │ Service  │ │  Service     │
│   MySQL     │ │  :8082   │ │  :8083   │ │  :8084   │ │  :8085   │ │   :8088      │
│             │ │  MySQL   │ │  MySQL   │ │PostgreSQL│ │ MongoDB  │ │  PostgreSQL  │
└──────┬──────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └──────┬───────┘
       │             │            │             │            │              │
       └─────────────┴────────────┴──────┬──────┴────────────┴──────────────┘
                                         │
                                         ▼
                          ┌──────────────────────────────┐
                          │    📨 Apache Kafka (KRaft)    │
                          │     3 Partitions | No ZK      │
                          │                              │
                          │  Topics:                     │
                          │  - notification-delivery     │
                          │  - event-log                 │
                          │  - user-updated              │
                          │  - patient-updated           │
                          │  - raw-hl7-message           │
                          └──────────────┬───────────────┘
                                         │
                          ┌──────────────┴───────────────┐
                          ▼                              ▼
                ┌──────────────────┐          ┌──────────────────┐
                │  Notification    │          │   Monitoring     │
                │   Service :8086 │          │   Service :8088  │
                │   (Email/SMS)   │          │   (Audit Logs)   │
                └──────────────────┘          └──────────────────┘

                          ┌──────────────────────────────┐
                          │  🔍 Eureka Discovery Server   │
                          │         Port: 8761            │
                          │   Service Registration &      │
                          │   Dynamic Load Balancing      │
                          └──────────────────────────────┘

                          ┌──────────────────────────────┐
                          │  📊 Observability Stack       │
                          │  Prometheus :9090 (Metrics)   │
                          │  Grafana    :3000 (Dashboard) │
                          └──────────────────────────────┘
```

---

## 🔄 Luồng Hoạt Động (Flow)

### 📋 Flow 1: Xác Thực và Quản Lý Người Dùng

```
[User] --POST /auth/login--> [API Gateway] --> [IAM Service]
                                                    │
                                        ┌───────────┴───────────┐
                                        │  1. Validate credentials │
                                        │  2. Generate JWT Token   │
                                        │  3. Return Access +      │
                                        │     Refresh Token        │
                                        └───────────┬───────────┘
                                                    │
                                          ┌─────────▼─────────┐
                                          │  Kafka: event-log  │
                                          │  (AOP auto-log)    │
                                          └─────────┬─────────┘
                                                    ▼
                                          [Monitoring Service]
                                          (Luu audit log vao DB)
```

### 🩸 Flow 2: Quy Trình Xét Nghiệm Máu (Core Business Flow)

```
                    ┌─────────────────────────────────────────────────────────────────┐
                    │              QUY TRINH XET NGHIEM MAU (CBC)                      │
                    └─────────────────────────────────────────────────────────────────┘

 (1) TIEP NHAN             (2) TAO Y LENH             (3) PHAN TICH MAU
 ┌──────────┐             ┌──────────────┐           ┌──────────────────┐
 │ Patient  │   ------>>  │  TestOrder   │  ------>> │   Instrument     │
 │ Service  │             │   Service    │           │    Service       │
 │          │             │              │           │                  │
 │- Dang ky │             │- Tao order   │           │- Ket noi may     │
 │  benh nhan│            │  xet nghiem  │           │  huyet hoc       │
 │- Cap nhat│             │- Gan may xet │           │- Phan tich mau   │
 │  ho so   │             │  nghiem      │           │  mau CBC         │
 │- OpenFeign│            │- Tracking    │           │- Sinh HL7 v2.5.1 │
 │  -> IAM  │             │  status      │           │  message         │
 └──────────┘             └──────────────┘           └────────┬─────────┘
                                                              │
                    (4) TRUYEN KET QUA HL7                     │  Kafka: raw-hl7-message
                    ┌─────────────────────────────────────────┘
                    ▼
 ┌──────────────────────────────────────────────────────────────────────────┐
 │                        HL7 v2.5.1 MESSAGE (ORU^R01)                      │
 │                                                                          │
 │  MSH|^~\&|BloodAnalyzer|Lab|LIS|Hospital|20260413||ORU^R01|MSG001|P|2.5│
 │  PID|1||PAT001||Nguyen Van A||19900101|M                                │
 │  OBR|1|ACC001|CBC^Complete Blood Count|||                               │
 │  OBX|1|NM|WBC^White Blood Cells||7.5|10^3/uL|4.0-10.0|N|||F           │
 │  OBX|2|NM|RBC^Red Blood Cells||4.8|10^6/uL|4.0-5.5|N|||F             │
 │  OBX|3|NM|HGB^Hemoglobin||14.2|g/dL|12.0-17.0|N|||F                   │
 │  OBX|4|NM|PLT^Platelets||250|10^9/L|150-400|N|||F                     │
 │  ... (11 chi so huyet hoc)                                              │
 └──────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
 (5) LUU KET QUA            (6) GIAM SAT
 ┌──────────────┐          ┌────────────────┐
 │  TestOrder   │          │   Monitoring   │
 │  Service     │          │    Service     │
 │              │          │                │
 │- Parse HL7   │          │- Luu raw HL7   │
 │- Luu ket qua│          │  vao DB        │
 │  xet nghiem  │          │- Event log     │
 │- Cap nhat    │          │- Audit trail   │
 │  trang thai  │          │                │
 └──────────────┘          └────────────────┘
```

### 📧 Flow 3: Notification Pipeline

```
[IAM Service] --Kafka: notification-delivery--> [Notification Service]
     │                                                    │
     │  Events:                                           │
     │  - User registered                        ┌───────┴────────┐
     │  - Password reset OTP                     │ Thymeleaf Email │
     │  - Password changed                       │   Templates     │
     │                                           │                 │
     │                                           │ - welcome-email │
     │                                           │ - otp-template  │
     │                                           │ - password-     │
     │                                           │   changed       │
     │                                           └───────┬────────┘
     │                                                    │
     │                                                    ▼
     │                                            [SMTP Gmail Server]
     └────────────────────────────────────────────────────┘
```

### 🔄 Flow 4: Cross-Service Data Sync

```
[IAM Service]                    [Patient Service]              [TestOrder Service]
     │                                 │                              │
     │  Kafka: user-updated            │                              │
     ├────────────────────────────────>│  Sync user profile           │
     │                                 │  changes                     │
     │                                 │                              │
     │                                 │  Kafka: patient-updated      │
     │                                 ├─────────────────────────────>│
     │                                 │                              │  Update patient
     │                                 │                              │  info in orders
     │                                 │                              │
     │         <---- OpenFeign (Sync REST Calls) ---->               │
     │  Khi can real-time data (VD: validate, get details)            │
```

---

## 📦 Danh Sách Microservices

| # | Service | Port | Database | Mô Tả |
|---|---------|------|----------|-------|
| 🌐 | **API Gateway** | `6789` | — | Reactive Gateway, JWT validation, route management, Swagger aggregation |
| 🔍 | **Discovery Server** | `8761` | — | Netflix Eureka Server cho service registration và discovery |
| 🔐 | **IAM Service** | `8081` | MySQL | Identity và Access Management: Auth, Users, Roles, eKYC, OAuth2 Social Login |
| 👤 | **Patient Service** | `8082` | MySQL | Quản lý thông tin bệnh nhân, hồ sơ y bạ |
| 📋 | **TestOrder Service** | `8083` | MySQL | Quản lý y lệnh xét nghiệm, kết quả, comments, audit history |
| 🏭 | **Warehouse Service** | `8084` | PostgreSQL | Quản lý kho thiết bị, máy xét nghiệm (inventory) |
| 🔬 | **Instrument Service** | `8085` | MongoDB | Mô phỏng máy huyết học, phân tích máu CBC, sinh HL7 message |
| 📧 | **Notification Service** | `8086` | — | Email notification qua Kafka consumer + Thymeleaf templates |
| 📊 | **Monitoring Service** | `8088` | PostgreSQL | Central audit log, event tracking, HL7 raw message storage |

---

## 🚀 Chức Năng Chi Tiết

### 🔐 IAM Service — Identity và Access Management

**Xác Thực và Phân Quyền**
- ✅ **Đăng ký / Đăng nhập** với JWT (Access Token + Refresh Token)
- ✅ **Token Introspection** — API Gateway gọi IAM để validate token
- ✅ **Role-Based Access Control (RBAC)** — Admin, Doctor, Lab Technician, Receptionist
- ✅ **Flyway Migration** — Quản lý schema versioning tự động

**OAuth2 Social Login**
- ✅ Đăng nhập qua **Google** (OAuth2 Client)
- ✅ Đăng nhập qua **Facebook** (OAuth2 Client)
- ✅ Auto-provisioning user từ social profile

**eKYC — Xác Minh Danh Tính**
- ✅ Tích hợp **VNPT eKYC API** (IDG Platform)
- ✅ **OCR** — Trích xuất thông tin từ ảnh CCCD/CMND (mặt trước + mặt sau)
- ✅ **Classify** — Phân loại tài liệu tự động
- ✅ Upload ảnh CCCD qua **Cloudinary CDN**

**Quản Lý Người Dùng**
- ✅ CRUD Users với validation đầy đủ
- ✅ Quên mật khẩu → Gửi OTP qua email → Reset password
- ✅ Upload/Update avatar qua Cloudinary
- ✅ Entity: `User`, `Role`, `Card`, `IdentityCard`, `PasswordResetOtp`

---

### 👤 Patient Service — Quản Lý Bệnh Nhân

- ✅ **CRUD** thông tin bệnh nhân (Patient)
- ✅ Auto-generate **Patient Code** duy nhất
- ✅ **Phân trang** (Pagination) với `PageResponse`
- ✅ **OpenFeign** gọi sang IAM Service để lấy thông tin user chi tiết
- ✅ **Kafka Consumer** — Lắng nghe event `user-updated` để sync data
- ✅ **Kafka Producer** — Publish `event-log` cho monitoring
- ✅ **Micrometer Tracing + Brave** — Distributed tracing gửi về Zipkin
- ✅ **JWT Security** — OAuth2 Resource Server validation

---

### 📋 TestOrder Service — Y Lệnh Xét Nghiệm

**Quản Lý Y Lệnh**
- ✅ **Tạo y lệnh** xét nghiệm (TestOrder) cho bệnh nhân
- ✅ **Gán máy xét nghiệm** (Instrument) cho từng order
- ✅ **Trạng thái order**: `PENDING` → `IN_PROGRESS` → `COMPLETED` → `CANCELLED`
- ✅ **Priority**: `NORMAL`, `URGENT`, `STAT`
- ✅ **Accession Number** tự động sinh duy nhất

**Kết Quả Xét Nghiệm**
- ✅ **Nhận kết quả HL7** từ Instrument Service qua Kafka
- ✅ **Parse HL7 message** → Lưu vào `TestResult` + `TestResultParameter`
- ✅ 11 chỉ số huyết học: WBC, RBC, HGB, HCT, MCV, MCH, MCHC, PLT, NEU%, LYM%, MON%
- ✅ Flag tự động: **N** (Normal), **H** (High), **L** (Low)

**Comments và Nhận Xét**
- ✅ CRUD comments trên mỗi test order
- ✅ **Audit Log Comments** — Mọi thao tác edit/delete đều được ghi lại
- ✅ `AuditLogComment` + `AuditDeleteComment` entities

**History và Traceability**
- ✅ `HistoryOrderAudit` — Ghi lại mọi thay đổi trạng thái order
- ✅ Cross-service data via **OpenFeign**: Patient, Warehouse, IAM

---

### 🏭 Warehouse Service — Quản Lý Kho Thiết Bị

- ✅ **CRUD** thiết bị (Instrument) trong kho
- ✅ **Trạng thái thiết bị**: `AVAILABLE`, `IN_USE`, `MAINTENANCE`, `DECOMMISSIONED`
- ✅ **Mapper** với MapStruct cho DTO conversion
- ✅ **PostgreSQL** — Relational storage cho inventory tracking
- ✅ **Phân trang và Tìm kiếm**
- ✅ AOP Event Log + Kafka producer cho audit trail

---

### 🔬 Instrument Service — Mô Phỏng Máy Huyết Học

> ⭐ **Đây là phần hay nhất của hệ thống** — Mô phỏng hoạt động của máy xét nghiệm huyết học thực tế

**Phân Tích Máu (Blood Analysis - CBC)**
- ✅ **Sinh chỉ số xét nghiệm** dựa trên phân bố xác suất:
  - 90% chỉ số trong khoảng bình thường
  - 6% bất thường thấp (Low)
  - 4% bất thường cao (High)
- ✅ **11 chỉ số huyết học** hoàn chỉnh: WBC, RBC, HGB, HCT, PLT, MCV, MCH, MCHC, NEU%, LYM%, MON%
- ✅ Reference ranges chuẩn y khoa quốc tế

**HL7 v2.5.1 Message Generation**
- ✅ **Sinh HL7 message chuẩn ORU^R01** đầy đủ các segment:
  - `MSH` — Message Header
  - `PID` — Patient Identification
  - `OBR` — Observation Request
  - `OBX` — Observation Result (11 segments cho 11 chỉ số)
- ✅ **Auto-flag**: N (Normal) / H (High) / L (Low) cho mỗi chỉ số
- ✅ Gửi raw HL7 qua **Kafka** topic `raw-hl7-message`

**Quản Lý Reagent (Hóa Chất)**
- ✅ CRUD Reagent (hóa chất xét nghiệm)
- ✅ **Reagent History** — Theo dõi lịch sử sử dụng
- ✅ **Audit Logs** — `ReagentAuditLog`, `ReagentUpdateAuditLog`
- ✅ Trạng thái: `INSTALLED`, `ACTIVE`, `EXPIRED`, `DEPLETED`

**Quản Lý Chế Độ Máy**
- ✅ **Instrument Mode Audit** — Ghi lại mọi thay đổi chế độ hoạt động
- ✅ MongoDB cho flexible document storage

---

### 📧 Notification Service — Hệ Thống Thông Báo

- ✅ **Kafka Consumer** — Lắng nghe topic `notification-delivery`
- ✅ **Email Templates** (Thymeleaf):
  - 📨 `welcome-email.html` — Chào mừng user mới
  - 🔑 `otp-template.html` — Gửi OTP cho forgot password
  - 🔒 `password-changed-template.html` — Xác nhận đổi mật khẩu
- ✅ **SMTP Integration** qua Gmail
- ✅ JWT Security cho internal API

---

### 📊 Monitoring Service — Trung Tâm Giám Sát

- ✅ **Event Log Consumer** — Thu thập logs từ tất cả services qua Kafka
- ✅ **Raw HL7 Consumer** — Lưu trữ raw HL7 messages cho traceability
- ✅ **Entity**: `EventLog`, `RawHL7Log`
- ✅ **PostgreSQL** — Persistent storage cho toàn bộ audit data
- ✅ **REST API** — Query logs, filter theo service/action/time

---

## ⚡ Tech Stack và Điểm Nổi Bật

### 🏛 Core Framework

| Tech | Version | Vai Trò |
|------|---------|---------|
| **Java** | 21 (LTS) | Virtual Threads, Pattern Matching, Record Classes |
| **Spring Boot** | 3.5.6 | Auto-configuration, Embedded Server, Production-ready |
| **Spring Cloud** | 2025.0.0 | Service Discovery, Gateway, OpenFeign, Config |
| **Spring Security** | 6.x | OAuth2 Authorization Server + Resource Server |

### 🌐 Microservices Infrastructure

| Tech | Vai Trò | Điểm Đặc Biệt |
|------|---------|----------------|
| **Spring Cloud Gateway** | API Gateway (Reactive) | WebFlux-based, Global JWT Filter, Route LoadBalancing |
| **Netflix Eureka** | Service Discovery | Dynamic service registration và client-side load balancing |
| **OpenFeign** | Declarative REST Client | Type-safe inter-service communication với auto token propagation |
| **Spring Boot Actuator** | Health Checks và Metrics | `/actuator/health`, `/actuator/prometheus`, `/actuator/info` |

### 📨 Event-Driven Architecture

| Tech | Vai Trò | Điểm Đặc Biệt |
|------|---------|----------------|
| **Apache Kafka** | Message Broker | KRaft mode (No Zookeeper), 3 partitions, JSON serialization |
| **Spring Kafka** | Producer/Consumer | Type-safe event publishing và consuming |
| **Event Topics** | 5 topics | `notification-delivery`, `event-log`, `user-updated`, `patient-updated`, `raw-hl7-message` |

### 💾 Polyglot Persistence (Multi-Database)

```
┌──────────────────────────────────────────────────────────────────┐
│                     DATABASE STRATEGY                             │
├──────────────────┬──────────────┬────────────────────────────────┤
│     MySQL        │  PostgreSQL  │         MongoDB                │
│  (Relational)    │ (Relational) │     (Document Store)           │
├──────────────────┼──────────────┼────────────────────────────────┤
│ - lab_manager    │ - warehouse  │ - instrument_db                │
│   (IAM)          │   _db        │   (Instrument Service)         │
│ - patient_db     │ - monitoring │                                │
│   (Patient)      │   (Audit)    │  Flexible schema cho           │
│ - testorder      │              │  reagent, instrument, HL7      │
│   _service       │  ACID cho    │  data dang document            │
│                  │  inventory   │                                │
│  User, Role,     │  tracking    │  Phu hop cho du lieu           │
│  Patient, Order  │              │  khong dong nhat               │
└──────────────────┴──────────────┴────────────────────────────────┘
```

### 🔐 Security Stack

| Tech | Vai Trò |
|------|---------|
| **Spring Security 6** | Core security framework |
| **JWT (jjwt 0.11.5)** | Token generation và validation |
| **OAuth2 Authorization Server** | Central auth provider (IAM Service) |
| **OAuth2 Resource Server** | Token validation at each service |
| **OAuth2 Client** | Social Login (Google, Facebook) |
| **VNPT eKYC** | Identity verification (CCCD OCR + Classify) |
| **Cloudinary** | Secure image upload (Avatar, CCCD) |

### 🛠 Developer Experience

| Tech | Vai Trò |
|------|---------|
| **MapStruct** | Compile-time DTO - Entity mapping |
| **Lombok** | Boilerplate code reduction |
| **Flyway** | Database migration versioning |
| **SpringDoc OpenAPI** | Auto-generated Swagger docs |
| **Spring AOP** | Cross-cutting concerns (Audit Logging) |
| **Spring DevTools** | Hot reload during development |
| **Thymeleaf** | Email HTML templates |

### 📊 Monitoring và Observability

| Tech | Vai Trò | Port |
|------|---------|------|
| **Prometheus** | Metrics collection và storage | `:9090` |
| **Grafana** | Metrics visualization và dashboards | `:3000` |
| **Micrometer** | Application metrics instrumentation | — |
| **Micrometer Tracing + Brave** | Distributed tracing | — |
| **Zipkin Reporter** | Trace data export | — |
| **Spring Boot Actuator** | Health, info, prometheus endpoints | — |

### 🐳 Containerization và CI/CD

| Tech | Vai Trò |
|------|---------|
| **Docker** | Multi-stage build (Maven build -> JRE runtime) |
| **Docker Compose** | Full-stack orchestration (15+ containers) |
| **GitHub Actions** | Automated build và push 9 images to Docker Hub |
| **Spring Profiles** | `dev` / `prod` environment separation |

---

## 📁 Cấu Trúc Thư Mục

```
dokploy-backend/
│
├── api-gateway/                         # Spring Cloud Gateway (Reactive)
│   └── src/main/java/ttldd/apigateway/
│       ├── config/
│       │   ├── AuthenticationFilter.java    # Global JWT validation filter
│       │   ├── SwaggerConfig.java           # Centralized Swagger aggregation
│       │   └── WebClientConfiguration.java  # WebClient for IAM introspection
│       ├── dto/                             # Request/Response DTOs
│       ├── repository/IamClient.java        # IAM WebClient
│       └── service/IamService.java          # Token introspection logic
│
├── discovery-server/                    # Netflix Eureka Server
│   └── src/main/java/ttldd/discoveryserver/
│       └── config/DiscoveryConfig.java
│
├── iam-service/                         # Identity & Access Management
│   └── src/main/java/ttldd/labman/
│       ├── aop/EventLogAspect.java          # AOP-based audit logging
│       ├── config/                          # Security, JWT, Cloudinary, OpenAPI
│       ├── consumer/                        # Kafka: patient-updated sync
│       ├── controller/                      # Auth, User, Role, PasswordReset
│       ├── dto/                             # 20+ DTOs (Request/Response/eKYC)
│       ├── entity/                          # User, Role, Card, PasswordResetOtp
│       ├── filter/                          # Custom security filter
│       ├── mapper/                          # MapStruct: UserMapper
│       ├── producer/                        # Kafka: event-log, notification
│       ├── repo/                            # JPA Repositories
│       ├── service/                         # 7 Service interfaces
│       │   ├── imp/                         # 7 Service implementations
│       │   └── VnptKycService.java          # eKYC integration
│       └── utils/                           # JWT, OTP, Date helpers
│
├── patient-service/                     # Patient Management
│   └── src/main/java/ttldd/patientservice/
│       ├── aop/EventLogAspect.java
│       ├── config/                          # Security, JWT, OpenAPI, Feign
│       ├── consumer/UserUpdatedConsumer.java # Kafka sync
│       ├── controller/PatientController.java
│       ├── entity/Patient.java
│       ├── mapper/PatientMapper.java
│       ├── producer/EventLogProducer.java
│       ├── repo/                            # PatientRepo + UserClient (Feign)
│       └── service/PatientService.java
│
├── testorder-services/                  # Test Order Management
│   └── src/main/java/ttldd/testorderservices/
│       ├── aop/EventLogAspect.java
│       ├── client/                          # Feign: Patient, Warehouse, User
│       ├── consumer/                        # Kafka: raw-hl7, user-updated
│       ├── controller/                      # TestOrder, TestResult, Comment
│       ├── dto/                             # 15+ DTOs
│       ├── entity/                          # TestOrder, TestResult, Comment...
│       ├── mapper/                          # MapStruct: Order, Result, Comment
│       ├── producer/EventLogProducer.java
│       ├── repository/                      # 8 JPA Repositories
│       └── service/                         # TestOrder, TestResult, Comment
│
├── warehouse-service/                   # Equipment Warehouse
│   └── src/main/java/ttldd/warehouseservice/
│       ├── aop/EventLogAspect.java
│       ├── config/                          # Security, JWT, OpenAPI, Feign
│       ├── controller/InstrumentController.java
│       ├── entity/Instrument.java
│       ├── mapper/InstrumentMapper.java
│       ├── producer/EventLogProducer.java
│       ├── repository/                      # InstrumentRepo + UserClient
│       └── service/InstrumentService.java
│
├── instrument-service/                  # Blood Analyzer Simulator
│   └── src/main/java/ttldd/instrumentservice/
│       ├── aop/EventLogAspect.java
│       ├── client/                          # Feign: Patient, TestOrder, Warehouse
│       ├── config/                          # Security, JWT, OpenAPI, Kafka
│       ├── controller/                      # BloodAnalysis, Instrument, Reagent
│       ├── entity/                          # Reagent, Instrument, HL7, AuditLog
│       ├── producer/                        # Kafka: raw-hl7-message, event-log
│       ├── repository/                      # 6 MongoDB/JPA Repositories
│       ├── service/                         # BloodAnalysis, Instrument, Reagent
│       └── utils/
│           ├── HL7Utils.java                # HL7 v2.5.1 message generator
│           └── JwtUtils.java
│
├── notification-service/                # Email Notification
│   └── src/main/java/ttldd/notification/
│       ├── config/                          # Security, JWT
│       ├── consumer/NotificationConsumer.java # Kafka consumer
│       ├── service/                         # EmailService, EmailTemplateService
│       └── exception/GlobalException.java
│
├── monitoring-service/                  # Central Audit & Monitoring
│   └── src/main/java/ttldd/monitoringservice/
│       ├── consumer/                        # Kafka: event-log, raw-hl7-message
│       ├── controller/MonitoringController.java
│       ├── entity/                          # EventLog, RawHL7Log
│       ├── repo/                            # EventLogRepo, RawHL7LogRepo
│       └── service/EventLogService.java
│
├── init/                                # Database Init Scripts
│   ├── mysql/init.sql                       # lab_manager, patient_db, testorder
│   └── postgres/init.sql                    # warehouse_db, monitoring
│
├── docker-compose.yml                   # Full-stack orchestration (15+ services)
├── prometheus.yml                       # Metrics scrape configuration
└── .github/workflows/
    └── docker-microservices.yml         # CI/CD: Build & Push 9 Docker images
```

**Tổng cộng: `317` Java files | `9` Microservices | `5` Databases | `5` Kafka Topics**

---

## 🖥 Cài Đặt và Triển Khai

### Yêu Cầu

| Tool | Version |
|------|---------|
| Java | 21+ |
| Maven | 3.9+ |
| Docker | 20+ |
| Docker Compose | v2+ |

### 🐳 Triển Khai với Docker Compose (Recommended)

```bash
# 1. Clone repository
git clone <repository-url>
cd dokploy-backend

# 2. Khoi dong toan bo he thong
docker compose up -d

# 3. Kiem tra trang thai
docker compose ps

# 4. Xem logs
docker compose logs -f api-gateway
```

### 🔧 Triển Khai Development (Local)

```bash
# 1. Khoi dong infrastructure
docker compose up -d kafka mysql postgres mongodb

# 2. Khoi dong Eureka Server
cd discovery-server && ./mvnw spring-boot:run

# 3. Khoi dong tung service (moi terminal)
cd iam-service && ./mvnw spring-boot:run -Pdev
cd patient-service && ./mvnw spring-boot:run -Pdev
cd testorder-services && ./mvnw spring-boot:run -Pdev
cd warehouse-service && ./mvnw spring-boot:run -Pdev
cd instrument-service && ./mvnw spring-boot:run -Pdev
cd notification-service && ./mvnw spring-boot:run -Pdev
cd monitoring-service && ./mvnw spring-boot:run -Pdev

# 4. Khoi dong API Gateway (cuoi cung)
cd api-gateway && ./mvnw spring-boot:run -Pdev
```

### 🌐 Ports Mapping

| Service | Port | URL |
|---------|------|-----|
| API Gateway | `6789` | `http://localhost:6789` |
| Eureka Dashboard | `8761` | `http://localhost:8761` |
| Swagger UI | `6789` | `http://localhost:6789/swagger-ui.html` |
| Grafana | `3000` | `http://localhost:3000` (admin/admin) |
| Prometheus | `9090` | `http://localhost:9090` |
| Kafka | `9094` | `localhost:9094` (external) |
| MySQL | `3307` | `localhost:3307` (root/123456) |
| PostgreSQL | `5432` | `localhost:5432` (postgres/123456) |
| MongoDB | `27017` | `localhost:27017` (root/123456) |

---

## 📖 API Documentation

Hệ thống sử dụng **SpringDoc OpenAPI** với Swagger UI được tập trung (aggregate) tại API Gateway:

```
http://localhost:6789/swagger-ui.html
```

Swagger được chia theo service:

| Service | Swagger Path |
|---------|-------------|
| IAM Service | `/iam/v3/api-docs` |
| Patient Service | `/patient/v3/api-docs` |
| TestOrder Service | `/testOrder/v3/api-docs` |
| Warehouse Service | `/warehouse/v3/api-docs` |
| Instrument Service | `/instrument/v3/api-docs` |
| Monitoring Service | `/monitoring/v3/api-docs` |

### 🔗 API Prefix Convention

Tất cả API đều có prefix: **`/v1/api/{service}/...`**

```
POST   /v1/api/iam/auth/login
POST   /v1/api/iam/auth/register
GET    /v1/api/patient/patients
POST   /v1/api/orders/test-orders
GET    /v1/api/warehouse/instruments
POST   /v1/api/instrument/blood-analysis
GET    /v1/api/monitoring/event-logs
```

---

## 🔄 CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions CI/CD                          │
│                  (Trigger: push to main)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Checkout Source Code                                        │
│       │                                                          │
│  2. Login to Docker Hub (secrets)                               │
│       │                                                          │
│  3. Build & Push 9 Docker Images (parallel)                     │
│       ├── datdevv/iam-service:latest                             │
│       ├── datdevv/patient-service:latest                         │
│       ├── datdevv/testorder-service:latest                       │
│       ├── datdevv/warehouse-service:latest                       │
│       ├── datdevv/instrument-service:latest                      │
│       ├── datdevv/monitoring-service:latest                      │
│       ├── datdevv/notification-service:latest                    │
│       ├── datdevv/api-gateway:latest                             │
│       └── datdevv/eureka-service:latest                          │
│                                                                  │
│  4. Docker Compose Pull & Deploy (on server)                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Docker Multi-stage Build** (mỗi service):

```dockerfile
# Stage 1: Build
FROM maven:3.9.9-amazoncorretto-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime (lightweight)
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## 📊 Monitoring và Observability

### Prometheus Metrics

```yaml
# Scrape configuration
scrape_configs:
  - job_name: iam-service        # :8081/iam/actuator/prometheus
  - job_name: another-service    # :8082, :8083 /actuator/prometheus
  - job_name: api-gateway        # :6789/actuator/prometheus
```

### Grafana Dashboard

Truy cập `http://localhost:3000` (admin/admin) để:
- 📈 Xem JVM metrics (Heap, GC, Threads)
- 📊 HTTP request rate và latency
- 🔥 Kafka consumer lag monitoring
- 💚 Service health status

### AOP-based Audit Logging

```
Moi thao tac CREATE / UPDATE / DELETE tren toan he thong
         │
         ▼
[EventLogAspect] --Kafka--> [Monitoring Service] --> [PostgreSQL]
         │
   Tu dong capture:
   - Service name
   - Action (CREATE/UPDATE/DELETE/FORGOT_PASSWORD/RESET_PASSWORD)
   - Entity type
   - Performed by (JWT user)
   - Timestamp
   - Trace ID (UUID)
   - Status (SUCCESS/FAILURE/ERROR)
   - Message with emoji indicators
```

---

---

**Built with ❤️ using Spring Boot Microservices**

*Java 21 - Spring Boot 3.5 - Spring Cloud 2025 - Apache Kafka - Docker*
