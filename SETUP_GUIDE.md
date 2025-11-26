# คู่มือการ Setup และ Run App บน iPhone

## 📱 1. การ Run App บน iPhone

### วิธีที่ 1: ใช้ iOS Simulator (สำหรับทดสอบ)

1. **เปิด Xcode** (ต้องติดตั้งจาก Mac App Store)
2. **เปิด iOS Simulator:**
   ```bash
   open -a Simulator
   ```
3. **Run App:**
   ```bash
   flutter run
   ```
   หรือ
   ```bash
   flutter run -d "iPhone 15 Pro"  # ระบุ simulator ที่ต้องการ
   ```

### วิธีที่ 2: ใช้ iPhone จริง

1. **เชื่อมต่อ iPhone กับ Mac ผ่าน USB**
2. **เปิดใช้งาน Developer Mode บน iPhone:**
   - Settings > Privacy & Security > Developer Mode > เปิดใช้งาน
3. **Trust Computer:**
   - เมื่อเชื่อมต่อ iPhone จะมี popup ถาม "Trust This Computer?" > กด Trust
4. **ตรวจสอบว่า iPhone ถูก detect:**
   ```bash
   flutter devices
   ```
   ควรเห็น iPhone ของคุณในรายการ
5. **Run App:**
   ```bash
   flutter run
   ```
   หรือ
   ```bash
   flutter run -d <device-id>  # ใช้ device ID จาก flutter devices
   ```

### วิธีที่ 3: ใช้ Xcode (แนะนำสำหรับ production)

1. **เปิด Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
2. **เลือก Device:**
   - ที่ด้านบนของ Xcode เลือก iPhone simulator หรือ iPhone จริง
3. **กด Run (⌘R)** หรือคลิกปุ่ม Play

---

## 🔥 2. การตั้งค่า Firebase

### ขั้นตอนที่ 1: ตั้งค่า Firebase Console

1. **ไปที่ [Firebase Console](https://console.firebase.google.com/)**
2. **เลือกโปรเจกต์:** `app-donut` (ตาม projectId ใน firebase_options.dart)
3. **ตรวจสอบว่าได้เพิ่ม iOS App แล้ว:**
   - ไปที่ Project Settings > Your apps
   - ควรมี iOS app อยู่แล้ว (App ID: `1:764096540833:ios:58f97a0ff7decbe4f2c0e0`)

### ขั้นตอนที่ 2: ดาวน์โหลด GoogleService-Info.plist

1. **ใน Firebase Console:**
   - Project Settings > Your apps > iOS app
   - คลิก "Download GoogleService-Info.plist"
2. **วางไฟล์ในโปรเจกต์:**
   ```bash
   # วางไฟล์ GoogleService-Info.plist ไว้ที่:
   ios/Runner/GoogleService-Info.plist
   ```
3. **ตรวจสอบว่าไฟล์ถูกเพิ่มใน Xcode:**
   - เปิด `ios/Runner.xcworkspace` ใน Xcode
   - ตรวจสอบว่า `GoogleService-Info.plist` อยู่ใน Runner folder
   - ถ้าไม่มี ให้ลากไฟล์เข้าไปใน Xcode

### ขั้นตอนที่ 3: ตั้งค่า Firestore Database

1. **สร้าง Firestore Database:**
   - ไปที่ Firebase Console > Firestore Database
   - คลิก "Create database"
   - เลือก "Start in test mode" (สำหรับ development)
   - เลือก location (แนะนำ: `asia-southeast1` สำหรับประเทศไทย)

2. **ตั้งค่า Security Rules (สำคัญ!):**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Tasks collection
       match /tasks/{taskId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && 
           (request.auth.uid == resource.data.parentId || 
            request.auth.uid == resource.data.childId);
       }
       
       // Rewards collection
       match /rewards/{rewardId} {
         allow read: if request.auth != null;
         allow create, update, delete: if request.auth != null && 
           request.auth.uid == resource.data.parentId;
       }
       
       // Families collection
       match /families/{parentId}/children/{childId} {
         allow read, write: if request.auth != null && 
           request.auth.uid == parentId;
       }
       
       // Reward redemptions
       match /reward_redemptions/{redemptionId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update: if request.auth != null && 
           (request.auth.uid == resource.data.parentId || 
            request.auth.uid == resource.data.childId);
       }
     }
   }
   ```

3. **ตั้งค่า Authentication:**
   - ไปที่ Authentication > Sign-in method
   - เปิดใช้งาน "Email/Password"
   - เปิดใช้งาน "Anonymous" (ถ้าต้องการ)

### ขั้นตอนที่ 4: ตั้งค่า iOS Capabilities

1. **เปิด Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **ตั้งค่า Signing & Capabilities:**
   - เลือก Runner target
   - ไปที่ "Signing & Capabilities"
   - เลือก Team (Apple Developer Account)
   - Bundle Identifier: `com.example.questForKids` (หรือเปลี่ยนตามต้องการ)

3. **ติดตั้ง Pods:**
   ```bash
   cd ios
   pod install
   cd ..
   ```

---

## 🎮 3. การปรับปรุงให้เหมือน Child Reward App

### ฟีเจอร์ที่ Child Reward App มี (และควรเพิ่ม):

1. **Gamification Elements:**
   - ⭐ ระบบดาว/คะแนนที่เห็นชัดเจน
   - 🏆 Achievement/Badges
   - 📊 Progress bars และ charts
   - 🎨 UI สีสันสดใส ดึงดูดเด็ก

2. **Task Management:**
   - 📝 หมวดหมู่งานที่หลากหลาย (งานบ้าน, การเรียน, ออกกำลังกาย)
   - ⏰ การแจ้งเตือน (Notifications)
   - 📸 อัปโหลดรูปภาพยืนยันการทำภารกิจ
   - ✅ Checklist สำหรับภารกิจที่ซับซ้อน

3. **Reward System:**
   - 🎁 รางวัลหลายประเภท (ของเล่น, กิจกรรม, สิทธิพิเศษ)
   - 💰 ระบบ Wallet/Points ที่เห็นชัดเจน
   - 🛒 Shopping cart สำหรับแลกรางวัล
   - 📅 กำหนดเวลาสำหรับรางวัล (เช่น "ไปเที่ยววันเสาร์")

4. **Family Features:**
   - 👨‍👩‍👧‍👦 Multiple children support
   - 📊 Dashboard สำหรับผู้ปกครอง
   - 📈 Reports และ Statistics
   - 💬 Chat/Message ระหว่าง parent-child

5. **Social Features:**
   - 🏅 Leaderboard (ถ้าต้องการ)
   - 📸 Share achievements

### แผนการปรับปรุง:

#### Phase 1: UI/UX Improvements
- [ ] เพิ่มสีสันและ animations
- [ ] ปรับ UI ให้เหมาะกับเด็ก (ใช้ emoji, icons สีสัน)
- [ ] เพิ่ม progress indicators
- [ ] ปรับ theme colors ให้สวยงามขึ้น

#### Phase 2: Enhanced Features
- [ ] เพิ่มรูปภาพสำหรับ tasks และ rewards
- [ ] เพิ่ม notification system
- [ ] เพิ่ม achievement/badge system
- [ ] เพิ่ม statistics dashboard

#### Phase 3: Advanced Features
- [ ] Photo upload สำหรับ task completion
- [ ] Recurring tasks (งานที่ทำซ้ำ)
- [ ] Task templates
- [ ] Reward approval workflow

---

## 🚀 Quick Start Commands

```bash
# 1. ตรวจสอบ devices
flutter devices

# 2. Run บน iOS simulator
flutter run

# 3. Run บน iPhone จริง
flutter run -d <device-id>

# 4. Build สำหรับ iOS
flutter build ios

# 5. Clean และ rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## ⚠️ Troubleshooting

### ปัญหา: "No devices found"
**แก้ไข:**
- ตรวจสอบว่า iPhone ถูกเชื่อมต่อและ trust computer แล้ว
- ตรวจสอบว่า Developer Mode เปิดอยู่บน iPhone
- รัน `flutter devices` เพื่อดูรายการ devices

### ปัญหา: "Firebase not initialized"
**แก้ไข:**
- ตรวจสอบว่า `GoogleService-Info.plist` อยู่ใน `ios/Runner/`
- ตรวจสอบว่า Bundle ID ใน Xcode ตรงกับ Firebase
- รัน `cd ios && pod install && cd ..`

### ปัญหา: "Pod install failed"
**แก้ไข:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

---

## 📝 Checklist ก่อน Run

- [ ] ติดตั้ง Xcode แล้ว
- [ ] ดาวน์โหลด `GoogleService-Info.plist` และวางไว้ที่ `ios/Runner/`
- [ ] ตั้งค่า Firestore Database ใน Firebase Console
- [ ] ตั้งค่า Security Rules
- [ ] เปิดใช้งาน Email/Password Authentication
- [ ] รัน `pod install` ในโฟลเดอร์ ios
- [ ] ตั้งค่า Signing & Capabilities ใน Xcode
- [ ] เชื่อมต่อ iPhone หรือเปิด iOS Simulator

---

**หมายเหตุ:** สำหรับการ deploy ขึ้น App Store ต้องมี Apple Developer Account ($99/ปี) และต้องตั้งค่าเพิ่มเติมใน Xcode

