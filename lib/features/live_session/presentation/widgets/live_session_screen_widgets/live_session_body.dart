import 'package:al_mobdea_admin/features/live_session/presentation/cubit/live_session_cubit.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/cubit/live_session_state.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/live_session_empty_view.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/live_session_form.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/live_session_loading_skeleton.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/live_session_saved_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveSessionBody extends StatefulWidget {
  const LiveSessionBody({super.key});

  @override
  State<LiveSessionBody> createState() {
    return _LiveSessionBodyState();
  }
}

class _LiveSessionBodyState extends State<LiveSessionBody> {
  bool _isFormVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveSessionCubit, LiveSessionState>(
      listenWhen: (previous, current) {
        return previous.status != current.status &&
            current.status == LiveSessionStatus.deleteSuccess;
      },
      listener: (context, state) {
        if (_isFormVisible) {
          setState(() {
            _isFormVisible = false;
          });
        }
      },
      child: BlocBuilder<LiveSessionCubit, LiveSessionState>(
        builder: (context, state) {
          final isInitialLoading =
              state.status == LiveSessionStatus.initial ||
              state.status == LiveSessionStatus.loading;

          if (isInitialLoading && !state.hasLiveSession) {
            return const LiveSessionLoadingSkeleton();
          }

          if (state.hasLiveSession) {
            return LiveSessionSavedContent(
              liveSession: state.liveSession!,
              isDeleting: state.isDeleting,
            );
          }

          if (_isFormVisible) {
            return LiveSessionForm(state: state);
          }

          return LiveSessionEmptyView(
            onAddPressed: () {
              setState(() {
                _isFormVisible = true;
              });
            },
          );
        },
      ),
    );
  }
}
