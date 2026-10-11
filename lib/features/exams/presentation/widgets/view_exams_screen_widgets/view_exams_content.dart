import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/view_exams_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/view_exams_state.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/view_exams_screen_widgets/view_exams_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewExamsContent extends StatelessWidget {
  const ViewExamsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: const CustomHeaderBar(title: 'إدارة الاختبارات', showProfileIcon: true),
        backgroundColor: ColorPalette.background,
        body: BackgroundStudentLayout(
          child: SafeArea(
            child: AppNetworkAwareContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: <Widget>[
                        SliverToBoxAdapter(child: verticalSpace(24)),
                        const ViewExamsStateView(),
                      ],
                    ),
                  ),
                  _buildFixedAddButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedAddButton(BuildContext context) {
    return BlocSelector<ViewExamsCubit, ViewExamsState, bool>(
      selector: (ViewExamsState state) {
        return state is ViewExamsEmpty || state is ViewExamsSuccess;
      },
      builder: (BuildContext context, bool shouldShowButton) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: shouldShowButton
              ? Container(
                  key: const ValueKey<String>('add-exam-button'),
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  child: AppAnimations.screenSection(
                    delay: 360,
                    child: CustomButton(
                      text: 'إنشاء اختبار جديد',
                      onPressed: () {
                        Navigator.of(context).pushNamed(RouteNames.addExamScreen);
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey<String>('hidden-add-exam-button')),
        );
      },
    );
  }
}
