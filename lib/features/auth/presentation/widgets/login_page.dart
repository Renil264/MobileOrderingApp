import 'package:concession_tracker_ui/features/auth/data/repositories/login_repository_datsource.dart';

import 'package:concession_tracker_ui/features/auth/presentation/pages/select_market_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

        // ✅ CORRECT — Pass UseCase directly
        return LoginBloc(useCase);
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is LoginSuccess) {
            Navigator.pop(context); // remove loader

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SelectMarketPage()),
            );
          }

          if (state is LoginFailure) {
            Navigator.pop(context); // remove loader if open

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), // ✅ correct property
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
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
              Positioned.fill(
                child: Image.asset(
                  'assets/login_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
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
