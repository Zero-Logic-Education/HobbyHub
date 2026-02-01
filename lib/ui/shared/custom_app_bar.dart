import 'package:flutter/material.dart';
import 'package:hobby_hub/core/theme/app_colors.dart';
import 'package:hobby_hub/core/theme/app_spacing.dart';
import 'package:hobby_hub/core/theme/app_typography.dart';

/// Кастомная AppBar с гибким стилем
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final VoidCallback? onLeadingTap;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final bool showDivider;
  final PreferredSizeWidget? bottom;
  final TextStyle? titleStyle;

  const CustomAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.onLeadingTap,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.showDivider = false,
    this.bottom,
    this.titleStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            AppTypography.headingMedium.copyWith(
              color: titleColor ?? AppColors.textPrimary,
            ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      surfaceTintColor: Colors.transparent,
      leading: leading != null
          ? GestureDetector(
              onTap: onLeadingTap ?? () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: leading,
              ),
            )
          : GestureDetector(
              onTap: onLeadingTap ?? () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
      actions: actions,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: AppColors.textHint.withValues(alpha: 0.2),
              ),
            )
          : bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(AppSpacing.appBarHeight +
          (bottom?.preferredSize.height ?? 0));
}

/// AppBar для главного экрана с заголовком и поиском
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final ValueChanged<String>? onSearch;
  final List<Widget>? actions;
  final VoidCallback? onSearchTap;

  const HomeAppBar({
    required this.title,
    this.showSearch = false,
    this.onSearch,
    this.actions,
    this.onSearchTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTypography.headingMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: [
        if (showSearch)
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: onSearchTap,
              child: Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        if (actions != null) ...actions!,
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AppColors.textHint.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppSpacing.appBarHeight + 1);
}

/// AppBar с поиском
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBackTap;
  final TextEditingController? controller;

  const SearchAppBar({
    this.hintText = 'Поиск...',
    this.onChanged,
    this.onBackTap,
    this.controller,
    super.key,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(AppSpacing.appBarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: widget.onBackTap ?? () => Navigator.of(context).pop(),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
      title: Container(
        decoration: BoxDecoration(
          color: AppColors.lightPink,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(
                Icons.search,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),
                  )
                : null,
          ),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// AppBar профиля с заголовком и меню
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBackTap;

  const ProfileAppBar({
    required this.title,
    this.onSettingsTap,
    this.onBackTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTypography.headingMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: onBackTap ?? () => Navigator.of(context).pop(),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onSettingsTap,
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AppColors.textHint.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppSpacing.appBarHeight + 1);
}
