import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatefulWidget {
  final String labelText;
  final bool isPassword;
  final TextEditingController? input_Controller;

  const InputField({
    Key? key,
    required this.labelText,
    this.isPassword = false,
    this.input_Controller,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _passwordState = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 7, top: 10),
          child: Text(
            widget.labelText,
            style: GoogleFonts.mali(
              color: Color(0xFF5C5C5C),
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          obscureText: widget.isPassword ? _passwordState : false,
          controller: widget.input_Controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 2),
            ),
            fillColor: Colors.white, // สีพื้นหลัง
            filled: true,
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _passwordState
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFF5C5C5C),
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordState = !_passwordState;
                        });
                      },
                    )
                    : null,
          ),
          style: GoogleFonts.mali(
            color: Color(0xFF464646),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
