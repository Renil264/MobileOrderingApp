import 'package:concession_tracker_ui/features/auth/data/repositories/login_repository_datsource.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/select_market_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/constants/app_colors.dart';
import '../pages/login_form.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/datasources/login_remote_datasource.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return BlocProvider(
      create: (_) {
        final remoteDataSource = LoginRemoteDatasource();
        final repository = LoginRepositoryImpl(remoteDataSource);
        final useCase = LoginUseCase(repository);

        return LoginBloc(useCase);
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {

          /// 🔄 LOADING STATE
          if (state is LoginLoading) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.loading,
              title: 'Please wait',
              text: 'Logging you in...',
              barrierDismissible: false,
            );
          }

          /// ✅ SUCCESS STATE
          if (state is LoginSuccess) {
            // Close loading popup
            Navigator.of(context, rootNavigator: true).pop();

            // Navigate directly (NO SUCCESS POPUP)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SelectMarketPage(),
              ),
            );
          }

          /// ❌ FAILURE STATE
          if (state is LoginFailure) {
            // Close loading popup if visible
            Navigator.of(context, rootNavigator: true).pop();

            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Login Failed',
              text: state.message,
              confirmBtnText: 'OK',
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              /// Background Gradient
              Container(
                width: size.width,
                height: size.height,
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

              /// Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/login_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              /// Gradient Overlay
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

              /// Login Form
              SafeArea(
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
                      child: const LoginForm(),
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