import 'package:concession_tracker_ui/features/auth/presentation/bloc/signup/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/register_user.dart';
import '../pages/signup_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return BlocProvider(
      create: (context) => AuthBloc(
        RegisterUser(
          AuthRepositoryImpl(
            AuthRemoteDataSourceImpl(http.Client()),
          ),
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            /// 1️⃣ BASE GRADIENT
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gradientBottom,
                      AppColors.gradientTop,
                    ],
                  ),
                ),
              ),
            ),

            /// 2️⃣ BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                'assets/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),

            /// 3️⃣ LIGHT GRADIENT OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gradientBottom.withOpacity(0.85),
                      AppColors.gradientTop.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            /// 4️⃣ CONTENT
            SafeArea(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height - padding.vertical,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: 24,
                      ),
                      child: const SignUpForm(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
