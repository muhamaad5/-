# الآلة الحاسبة - Flutter

تطبيق آلة حاسبة بسيط باللغة العربية، بواجهة داكنة وأزرار واضحة.

## المزايا
- العمليات الأساسية: الجمع والطرح والضرب والقسمة
- النسبة المئوية
- تغيير الإشارة
- حذف آخر خانة ومسح كامل
- يعرض النتيجة أثناء الكتابة
- لا يحتاج إلى أي مكتبات خارجية

## التشغيل محلياً
1. ثبّت Flutter و Android Studio.
2. افتح مجلد المشروع.
3. نفّذ:
   ```bash
   flutter pub get
   flutter run
   ```

## استخراج APK يدوياً
```bash
flutter build apk --release
```
ستجد الملف هنا:
`build/app/outputs/flutter-apk/app-release.apk`

## البناء عبر GitHub و Codemagic
1. ارفع كامل محتويات هذا المجلد إلى مستودع GitHub جديد.
2. من Codemagic اختر Add application ثم اربط مستودع GitHub.
3. اختر Flutter كتقنية المشروع.
4. سيقرأ Codemagic ملف `codemagic.yaml` الموجود في جذر المشروع.
5. شغّل workflow باسم `Android APK`.
6. بعد نجاح البناء نزّل `app-release.apk` من Artifacts.

ملاحظة: هذا مشروع Flutter كامل المصدر، وليس ملف APK جاهزاً. Codemagic هو الذي سيحوّله إلى APK بعد ربط المستودع وتشغيل البناء.
