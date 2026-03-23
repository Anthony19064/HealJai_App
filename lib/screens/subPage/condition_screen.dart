import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/conditionProvider.dart';

class ConditionScreen extends StatefulWidget {
  const ConditionScreen({super.key});

  @override
  State<ConditionScreen> createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen> {
  bool isAccepted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: ZoomIn(
        duration: Duration(milliseconds: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                "เงื่อนไขการใช้งาน (Terms of Use)",
                style: GoogleFonts.mali(
                  fontSize: 20,
                  height: 1.5,
                  color: Color(0xFF464646),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '''ในการสมัครสมาชิกเพื่อใช้งาน Healjai ท่านตกลงยินยอมให้เราประมวลผลข้อมูลดังต่อไปนี้:''',
                        style: GoogleFonts.mali(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF464646),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF464646),
                          ),
                          children: [
                            TextSpan(
                              text: "1. การจัดเก็บข้อมูล: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  "ยินยอมให้จัดเก็บ ชื่อผู้ใช้ อีเมล และบันทึกการใช้งาน (Log) เพื่อวัตถุประสงค์ในการยืนยันตัวตนและรักษาความปลอดภัย",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF464646),
                          ),
                          children: [
                            TextSpan(
                              text: "2.ระยะเวลาการจัดเก็บ: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  "เราจะเก็บข้อมูลไว้ตลอดระยะเวลาที่ท่านเป็นสมาชิก และจะทำลายข้อมูลภายใน 30 วันหลังจากท่านแจ้งลบบัญชี",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF464646),
                          ),
                          children: [
                            TextSpan(
                              text: "3.การเข้าถึงข้อมูล: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  '''ข้อมูลแชทส่วนตัวจะถูกจำกัดการเข้าถึงเฉพาะผู้ดูแลระบบ "เมื่อมีการแจ้งรายงานความผิดกฎระเบียบ" เท่านั้น''',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF464646),
                          ),
                          children: [
                            TextSpan(
                              text: "4.การถอนความยินยอม: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  "ท่านมีสิทธิถอนความยินยอมหรือขอให้ลบข้อมูลส่วนบุคคลได้ทุกเมื่อ โดยส่งคำขอมาที่อีเมลผู้พัฒนา",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isAccepted,
                    onChanged: (value) {
                      setState(() {
                        isAccepted = value!;
                      });
                    },
                    activeColor: Color(0xFF78B465),
                  ),
                  Expanded(
                    child: Text(
                      "ฉันยอมรับเงื่อนไขการใช้งาน",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF464646),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async{
                      if (isAccepted) {
                        //
                        await setConditionState();
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAccepted ? const Color(0xFF78B465) : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "ถัดไป",
                      style: GoogleFonts.mali(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
