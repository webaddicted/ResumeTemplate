import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateful_widget.dart';
import 'package:get/get.dart';
import 'package:template/features/resume/data/ai_enhancement_service.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/ai_suggestion_card.dart';
import 'package:template/global/widgets/form_widgets.dart';
import 'package:template/features/resume/domain/ai_suggestion_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';

/// Binds an [AiSuggestion] to the action that applies its text to the model.
class _FormSuggestion {
  _FormSuggestion(this.suggestion, this.apply);
  final AiSuggestion suggestion;
  final void Function(String text) apply;
}

/// Screens 2–7 — the 6-step data collection wizard.
class FormStepsPage extends BaseStatefulWidget {
  const FormStepsPage({super.key, required this.data, this.initialStep = 1});

  final ResumeData data;
  final int initialStep;

  @override
  State<FormStepsPage> createState() => _FormStepsPageState();
}

class _FormStepsPageState extends BaseState<FormStepsPage> {
  static const _titles = [
    'Personal & Contact',
    'Summary & Expertise',
    'Work Experience',
    'Skills & Projects',
    'Education',
    'More Info',
  ];

  late int _step = widget.initialStep;

  /// AI suggestions generated for the current step (cleared on navigation).
  final List<_FormSuggestion> _suggestions = [];

  ResumeData get d => widget.data;

  bool get _hasPendingSuggestions => _suggestions
      .any((s) => s.suggestion.status == SuggestionStatus.pending);

  void _next() {
    if (_step == 1 && d.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name to continue.')),
      );
      return;
    }
    // The AI Assist workflow requires resolving each suggestion first.
    if (_hasPendingSuggestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept, Edit, or Dismiss each AI suggestion first.'),
        ),
      );
      return;
    }
    if (_step < 6) {
      setState(() {
        _step++;
        _suggestions.clear();
      });
    } else {
      Get.toNamed(RoutersConst.resumePreview, arguments: d);
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() {
        _step--;
        _suggestions.clear();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Generate AI suggestions for the current step.
  void _runAiAssist() {
    final ai = AiEnhancement.instance;
    final next = <_FormSuggestion>[];

    switch (_step) {
      case 2:
        next.add(_FormSuggestion(
          ai.generateSummary(d),
          (t) => setState(() => d.summary = t),
        ));
        final skills = ai.suggestSkills(d);
        next.add(_FormSuggestion(skills, (t) {
          setState(() => d.expertise = [
                ...d.expertise.where((e) => e.trim().isNotEmpty),
                ...t.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
              ]);
        }));
      case 3:
        if (d.experience.isEmpty) d.experience.add(Experience());
        final e = d.experience.first;
        final original =
            e.bullets.firstWhere((b) => b.trim().isNotEmpty, orElse: () => '');
        next.add(_FormSuggestion(
          ai.enhanceExperienceBullet(
            role: e.role,
            company: e.company,
            original: original,
          ),
          (t) => setState(() {
            if (e.bullets.isEmpty) {
              e.bullets.add(t);
            } else {
              e.bullets[0] = t;
            }
          }),
        ));
      case 4:
        final skills = ai.suggestSkills(d);
        next.add(_FormSuggestion(skills, (t) {
          setState(() {
            if (d.techSkills.isEmpty) {
              d.techSkills.add(TechSkillGroup(category: 'Skills', skills: t));
            } else {
              final g = d.techSkills.first;
              g.skills =
                  g.skills.trim().isEmpty ? t : '${g.skills}, $t';
            }
          });
        }));
        if (d.projects.isNotEmpty && d.projects.first.name.trim().isNotEmpty) {
          final p = d.projects.first;
          next.add(_FormSuggestion(
            ai.enhanceProject(
                name: p.name, tech: p.tech, original: p.description),
            (t) => setState(() => p.description = t),
          ));
        }
      case 6:
        next.add(_FormSuggestion(
          ai.recommendCertifications(d),
          (t) => setState(() {
            final lines = t.split('\n').where((l) => l.trim().isNotEmpty);
            for (final l in lines) {
              d.certificates.add(Certificate(title: l.trim()));
            }
          }),
        ));
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Assist is available on the content steps (2–6).'),
          ),
        );
        return;
    }

    setState(() {
      _suggestions
        ..clear()
        ..addAll(next);
    });
  }

  void _acceptSuggestion(_FormSuggestion fs) {
    fs.apply(fs.suggestion.suggested);
    setState(() => fs.suggestion.status = SuggestionStatus.accepted);
  }

  Future<void> _editSuggestion(_FormSuggestion fs) async {
    final controller = TextEditingController(text: fs.suggestion.suggested);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit suggestion'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      fs.suggestion.suggested = result.trim();
      fs.apply(result.trim());
      setState(() => fs.suggestion.status = SuggestionStatus.edited);
    }
  }

  void _dismissSuggestion(_FormSuggestion fs) {
    setState(() => fs.suggestion.status = SuggestionStatus.dismissed);
  }

  /// Suggestion cards for the current step, rendered above its fields.
  Widget _aiSuggestions() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final fs in _suggestions)
          AiSuggestionCard(
            suggestion: fs.suggestion,
            onAccept: () => _acceptSuggestion(fs),
            onEdit: () => _editSuggestion(fs),
            onDismiss: () => _dismissSuggestion(fs),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  Widget initBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_step - 1]),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        actions: [
          if (_step >= 2)
            TextButton.icon(
              onPressed: _runAiAssist,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('AI Assist'),
            ),
          TextButton(
            onPressed: () =>
                Get.toNamed(RoutersConst.resumePreview, arguments: d),
            child: const Text('Preview'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.formMaxWidth),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: StepIndicator(
                    current: _step,
                    total: 6,
                    titles: _titles,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _aiSuggestions(),
                        switch (_step) {
                          1 => _step1(),
                          2 => _step2(),
                          3 => _step3(),
                          4 => _step4(),
                          5 => _step5(),
                          _ => _step6(),
                        },
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      if (_step > 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _back,
                            child: const Text('Back'),
                          ),
                        ),
                      if (_step > 1) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _next,
                          child: Text(_step < 6 ? 'Next' : 'Preview Resume'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Step 1 — Personal & Contact -------------------------------------
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Who are you?',
          subtitle: 'This appears in the header of every template.',
        ),
        PhotoPickerField(
          photo: d.photo,
          onChanged: (bytes) => setState(() => d.photo = bytes),
        ),
        FormField2(
          label: 'Full Name',
          required: true,
          value: d.name,
          hint: 'e.g. Deepak Sharma',
          onChanged: (v) => d.name = v,
        ),
        FormField2(
          label: 'Job Title / Role',
          required: true,
          value: d.jobTitle,
          hint: 'e.g. Technical Lead — Mobile',
          onChanged: (v) => d.jobTitle = v,
        ),
        FormField2(
          label: 'Tagline',
          value: d.tagline,
          hint: 'e.g. 9+ Years | 30+ Apps | Technical Lead',
          onChanged: (v) => d.tagline = v,
        ),
        const SectionHeader(title: 'Contact'),
        FormField2(
          label: 'Mobile',
          required: true,
          value: d.phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => d.phone = v,
        ),
        FormField2(
          label: 'Email',
          required: true,
          value: d.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => d.email = v,
        ),
        FormField2(
          label: 'Location',
          value: d.location,
          hint: 'City, Country',
          onChanged: (v) => d.location = v,
        ),
        FormField2(
          label: 'Website',
          value: d.website,
          keyboardType: TextInputType.url,
          onChanged: (v) => d.website = v,
        ),
        FormField2(
          label: 'LinkedIn',
          value: d.linkedin,
          keyboardType: TextInputType.url,
          onChanged: (v) => d.linkedin = v,
        ),
        FormField2(
          label: 'GitHub',
          value: d.github,
          keyboardType: TextInputType.url,
          onChanged: (v) => d.github = v,
        ),
        FormField2(
          label: 'Other Link',
          value: d.otherLink,
          hint: 'Behance, Dribbble, …',
          keyboardType: TextInputType.url,
          onChanged: (v) => d.otherLink = v,
        ),
      ],
    );
  }

  // ---- Step 2 — Summary & Expertise -------------------------------------
  Widget _step2() {
    if (d.expertise.isEmpty) d.expertise = [''];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Professional Summary',
          subtitle: '2–3 sentences recommended.',
        ),
        FormField2(
          label: 'Summary',
          value: d.summary,
          maxLines: 5,
          hint: 'Mobile technical lead with 9+ years of experience…',
          onChanged: (v) => d.summary = v,
        ),
        const SectionHeader(
          title: 'Expertise',
          subtitle: 'Your headline strengths, one per line.',
        ),
        DynamicTextList(
          items: d.expertise,
          addLabel: 'Add expertise',
          hint: 'e.g. Mobile Architecture (BLoC, MVVM)',
          onChanged: (items) => setState(() => d.expertise = items),
        ),
      ],
    );
  }

  // ---- Step 3 — Work Experience ------------------------------------------
  Widget _step3() {
    if (d.experience.isEmpty) d.experience.add(Experience());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Work Experience',
          subtitle: 'Most recent first. Leave blank to skip this section.',
        ),
        for (var i = 0; i < d.experience.length; i++)
          EntryCard(
            title: 'Experience ${i + 1}',
            onRemove: d.experience.length > 1
                ? () => setState(() => d.experience.removeAt(i))
                : null,
            child: _experienceFields(d.experience[i]),
          ),
        AddEntryButton(
          label: 'Add experience',
          onTap: () => setState(() => d.experience.add(Experience())),
        ),
      ],
    );
  }

  Widget _experienceFields(Experience e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormField2(
          label: 'Job Title / Role',
          required: true,
          value: e.role,
          onChanged: (v) => e.role = v,
        ),
        FormField2(
          label: 'Company',
          required: true,
          value: e.company,
          onChanged: (v) => e.company = v,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormField2(
                label: 'Start Date',
                required: true,
                value: e.startDate,
                hint: 'Jan 2020',
                onChanged: (v) => e.startDate = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'End Date',
                required: true,
                value: e.endDate,
                hint: 'Present',
                onChanged: (v) => e.endDate = v,
              ),
            ),
          ],
        ),
        FormField2(
          label: 'Location',
          value: e.location,
          onChanged: (v) => e.location = v,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'Achievements / responsibilities',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        DynamicTextList(
          items: e.bullets,
          addLabel: 'Add bullet point',
          hint: 'e.g. Cut cold-start time by 45%…',
          onChanged: (items) => setState(() => e.bullets = items),
        ),
      ],
    );
  }

  // ---- Step 4 — Technical Skills & Projects --------------------------------
  Widget _step4() {
    if (d.techSkills.isEmpty) d.techSkills.add(TechSkillGroup());
    if (d.projects.isEmpty) d.projects.add(Project());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Technical Skills',
          subtitle: 'Grouped by category, comma-separated values.',
        ),
        for (var i = 0; i < d.techSkills.length; i++)
          EntryCard(
            title: 'Skill group ${i + 1}',
            onRemove: d.techSkills.length > 1
                ? () => setState(() => d.techSkills.removeAt(i))
                : null,
            child: Column(
              children: [
                FormField2(
                  label: 'Category',
                  value: d.techSkills[i].category,
                  hint: 'Languages / Frameworks / Tools / PM',
                  onChanged: (v) => d.techSkills[i].category = v,
                ),
                FormField2(
                  label: 'Skills',
                  value: d.techSkills[i].skills,
                  hint: 'Dart, Kotlin, Swift',
                  onChanged: (v) => d.techSkills[i].skills = v,
                ),
              ],
            ),
          ),
        AddEntryButton(
          label: 'Add skill group',
          onTap: () => setState(() => d.techSkills.add(TechSkillGroup())),
        ),
        const SectionHeader(title: 'Projects'),
        for (var i = 0; i < d.projects.length; i++)
          EntryCard(
            title: 'Project ${i + 1}',
            onRemove: d.projects.length > 1
                ? () => setState(() => d.projects.removeAt(i))
                : null,
            child: Column(
              children: [
                FormField2(
                  label: 'Project Name',
                  required: true,
                  value: d.projects[i].name,
                  onChanged: (v) => d.projects[i].name = v,
                ),
                FormField2(
                  label: 'Your Role',
                  value: d.projects[i].role,
                  hint: 'Tech Lead / Sole Developer',
                  onChanged: (v) => d.projects[i].role = v,
                ),
                FormField2(
                  label: 'Tech Stack',
                  value: d.projects[i].tech,
                  hint: 'Flutter, BLoC, Firebase',
                  onChanged: (v) => d.projects[i].tech = v,
                ),
                FormField2(
                  label: 'Description',
                  value: d.projects[i].description,
                  maxLines: 3,
                  hint: '1–2 sentences',
                  onChanged: (v) => d.projects[i].description = v,
                ),
                FormField2(
                  label: 'Link',
                  value: d.projects[i].link,
                  keyboardType: TextInputType.url,
                  hint: 'Play Store, GitHub, web URL',
                  onChanged: (v) => d.projects[i].link = v,
                ),
              ],
            ),
          ),
        AddEntryButton(
          label: 'Add project',
          onTap: () => setState(() => d.projects.add(Project())),
        ),
      ],
    );
  }

  // ---- Step 5 — Education ---------------------------------------------------
  Widget _step5() {
    if (d.education.isEmpty) d.education.add(Education());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Education'),
        for (var i = 0; i < d.education.length; i++)
          EntryCard(
            title: 'Education ${i + 1}',
            onRemove: d.education.length > 1
                ? () => setState(() => d.education.removeAt(i))
                : null,
            child: Column(
              children: [
                FormField2(
                  label: 'Degree',
                  required: true,
                  value: d.education[i].degree,
                  hint: 'B.Tech Computer Science',
                  onChanged: (v) => d.education[i].degree = v,
                ),
                FormField2(
                  label: 'Institution',
                  required: true,
                  value: d.education[i].institution,
                  onChanged: (v) => d.education[i].institution = v,
                ),
                Row(
                  children: [
                    Expanded(
                      child: FormField2(
                        label: 'Start Year',
                        value: d.education[i].startYear,
                        onChanged: (v) => d.education[i].startYear = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormField2(
                        label: 'End Year',
                        value: d.education[i].endYear,
                        onChanged: (v) => d.education[i].endYear = v,
                      ),
                    ),
                  ],
                ),
                FormField2(
                  label: 'Grade / CGPA',
                  value: d.education[i].grade,
                  hint: '8.7 CGPA',
                  onChanged: (v) => d.education[i].grade = v,
                ),
              ],
            ),
          ),
        AddEntryButton(
          label: 'Add education',
          onTap: () => setState(() => d.education.add(Education())),
        ),
      ],
    );
  }

  // ---- Step 6 — More Info ----------------------------------------------------
  Widget _step6() {
    if (d.certificates.isEmpty) d.certificates.add(Certificate());
    if (d.patents.isEmpty) d.patents.add(Patent());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Personal Information',
          subtitle: 'All optional — empty fields are hidden on the resume.',
        ),
        FormField2(
          label: 'Address',
          value: d.personal.address,
          maxLines: 2,
          onChanged: (v) => d.personal.address = v,
        ),
        FormField2(
          label: 'Date of Birth',
          value: d.personal.dob,
          hint: '12 May 1993',
          onChanged: (v) => d.personal.dob = v,
        ),
        FormField2(
          label: 'Languages Known',
          value: d.personal.languages,
          hint: 'Hindi, English, Kannada',
          onChanged: (v) => d.personal.languages = v,
        ),
        FormField2(
          label: 'Hobbies / Interests',
          value: d.personal.hobbies,
          onChanged: (v) => d.personal.hobbies = v,
        ),
        const SectionHeader(title: 'Certificates & Recognition'),
        for (var i = 0; i < d.certificates.length; i++)
          EntryCard(
            title: 'Certificate ${i + 1}',
            onRemove: d.certificates.length > 1
                ? () => setState(() => d.certificates.removeAt(i))
                : null,
            child: Column(
              children: [
                FormField2(
                  label: 'Certificate Title',
                  value: d.certificates[i].title,
                  hint: 'Flutter & Dart – The Complete Guide',
                  onChanged: (v) => d.certificates[i].title = v,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FormField2(
                        label: 'Issuer',
                        value: d.certificates[i].issuer,
                        hint: 'Udemy',
                        onChanged: (v) => d.certificates[i].issuer = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormField2(
                        label: 'Year',
                        value: d.certificates[i].year,
                        onChanged: (v) => d.certificates[i].year = v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        AddEntryButton(
          label: 'Add certificate',
          onTap: () => setState(() => d.certificates.add(Certificate())),
        ),
        const SectionHeader(title: 'Patents (optional)'),
        for (var i = 0; i < d.patents.length; i++)
          EntryCard(
            title: 'Patent ${i + 1}',
            onRemove: d.patents.length > 1
                ? () => setState(() => d.patents.removeAt(i))
                : null,
            child: Column(
              children: [
                FormField2(
                  label: 'Patent Title',
                  value: d.patents[i].title,
                  onChanged: (v) => d.patents[i].title = v,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FormField2(
                        label: 'Patent Number',
                        value: d.patents[i].number,
                        onChanged: (v) => d.patents[i].number = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormField2(
                        label: 'Year',
                        value: d.patents[i].year,
                        onChanged: (v) => d.patents[i].year = v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        AddEntryButton(
          label: 'Add patent',
          onTap: () => setState(() => d.patents.add(Patent())),
        ),
      ],
    );
  }
}
