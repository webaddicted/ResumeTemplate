import 'dart:typed_data';

/// ResumeKit Pro — data model.
///
/// All fields are optional plain strings; empty sections are hidden when
/// the resume is rendered. The model is deliberately separated from any
/// template so the user can switch presentation without losing content.
class Experience {
  Experience({
    this.role = '',
    this.company = '',
    this.startDate = '',
    this.endDate = 'Present',
    this.location = '',
    List<String>? bullets,
  }) : bullets = bullets ?? [''];

  String role;
  String company;
  String startDate;
  String endDate;
  String location;
  List<String> bullets;

  bool get isEmpty =>
      role.trim().isEmpty &&
      company.trim().isEmpty &&
      bullets.every((b) => b.trim().isEmpty);
}

class TechSkillGroup {
  TechSkillGroup({this.category = '', this.skills = ''});

  String category;
  String skills;

  bool get isEmpty => category.trim().isEmpty && skills.trim().isEmpty;
}

class Project {
  Project({
    this.name = '',
    this.tech = '',
    this.role = '',
    this.description = '',
    this.link = '',
  });

  String name;
  String tech;
  String role;
  String description;
  String link;

  bool get isEmpty => name.trim().isEmpty && description.trim().isEmpty;
}

class Education {
  Education({
    this.degree = '',
    this.institution = '',
    this.startYear = '',
    this.endYear = '',
    this.grade = '',
  });

  String degree;
  String institution;
  String startYear;
  String endYear;
  String grade;

  bool get isEmpty => degree.trim().isEmpty && institution.trim().isEmpty;
}

class PersonalInfo {
  PersonalInfo({
    this.address = '',
    this.dob = '',
    this.languages = '',
    this.hobbies = '',
  });

  String address;
  String dob;
  String languages;
  String hobbies;

  bool get isEmpty =>
      address.trim().isEmpty &&
      dob.trim().isEmpty &&
      languages.trim().isEmpty &&
      hobbies.trim().isEmpty;
}

class Certificate {
  Certificate({this.title = '', this.issuer = '', this.year = ''});

  String title;
  String issuer;
  String year;

  bool get isEmpty => title.trim().isEmpty;
}

class Patent {
  Patent({this.title = '', this.number = '', this.year = ''});

  String title;
  String number;
  String year;

  bool get isEmpty => title.trim().isEmpty;
}

class ResumeData {
  ResumeData({
    this.name = '',
    this.jobTitle = '',
    this.tagline = '',
    this.phone = '',
    this.email = '',
    this.location = '',
    this.website = '',
    this.linkedin = '',
    this.github = '',
    this.otherLink = '',
    this.summary = '',
    this.templateId = 'modern_dark',
    List<Experience>? experience,
    List<String>? expertise,
    List<TechSkillGroup>? techSkills,
    List<Project>? projects,
    List<Education>? education,
    PersonalInfo? personal,
    List<Certificate>? certificates,
    List<Patent>? patents,
  })  : experience = experience ?? [],
        expertise = expertise ?? [],
        techSkills = techSkills ?? [],
        projects = projects ?? [],
        education = education ?? [],
        personal = personal ?? PersonalInfo(),
        certificates = certificates ?? [],
        patents = patents ?? [];

  String name;
  String jobTitle;
  String tagline;
  String phone;
  String email;
  String location;
  String website;
  String linkedin;
  String github;
  String otherLink;
  String summary;
  String templateId;

  /// Optional profile photo (raw image bytes), shown in template headers.
  Uint8List? photo;

  /// Raw extracted text of an uploaded source file (if any). Used only for
  /// ATS formatting analysis; never rendered.
  String sourceText = '';

  List<Experience> experience;
  List<String> expertise;
  List<TechSkillGroup> techSkills;
  List<Project> projects;
  List<Education> education;
  PersonalInfo personal;
  List<Certificate> certificates;
  List<Patent> patents;

  // ---- Section visibility helpers (empty sections are hidden) ----
  List<Experience> get filledExperience =>
      experience.where((e) => !e.isEmpty).toList();
  List<String> get filledExpertise =>
      expertise.where((e) => e.trim().isNotEmpty).toList();
  List<TechSkillGroup> get filledTechSkills =>
      techSkills.where((e) => !e.isEmpty).toList();
  List<Project> get filledProjects =>
      projects.where((e) => !e.isEmpty).toList();
  List<Education> get filledEducation =>
      education.where((e) => !e.isEmpty).toList();
  List<Certificate> get filledCertificates =>
      certificates.where((e) => !e.isEmpty).toList();
  List<Patent> get filledPatents => patents.where((e) => !e.isEmpty).toList();

  bool get hasContact =>
      phone.trim().isNotEmpty ||
      email.trim().isNotEmpty ||
      location.trim().isNotEmpty ||
      website.trim().isNotEmpty ||
      linkedin.trim().isNotEmpty ||
      github.trim().isNotEmpty ||
      otherLink.trim().isNotEmpty;

  /// Non-empty contact entries as (icon-hint, value) pairs.
  List<(String, String)> get contactItems => [
        if (phone.trim().isNotEmpty) ('phone', phone),
        if (email.trim().isNotEmpty) ('email', email),
        if (location.trim().isNotEmpty) ('location', location),
        if (website.trim().isNotEmpty) ('web', website),
        if (linkedin.trim().isNotEmpty) ('linkedin', linkedin),
        if (github.trim().isNotEmpty) ('github', github),
        if (otherLink.trim().isNotEmpty) ('link', otherLink),
      ];

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// One-tap sample data ("⚡ Load Sample").
  static ResumeData sample() => ResumeData(
        name: 'Deepak Sharma',
        jobTitle: 'Technical Lead — Mobile',
        tagline: '9+ Years | 30+ Apps | Technical Lead',
        phone: '+91 98765 43210',
        email: 'deepak.sharma@example.com',
        location: 'Bengaluru, India',
        linkedin: 'linkedin.com/in/deepaksharma',
        github: 'github.com/deepaksharma',
        summary:
            'Mobile technical lead with 9+ years of experience designing and '
            'shipping high-scale Flutter and native Android applications. '
            'Passionate about clean architecture, developer experience, and '
            'mentoring high-performing teams.',
        expertise: [
          'Mobile Architecture (BLoC, MVVM)',
          'Flutter & Dart at Scale',
          'CI/CD & Release Engineering',
          'Team Leadership & Mentoring',
          'Performance Optimisation',
        ],
        experience: [
          Experience(
            role: 'Technical Lead',
            company: 'FinPay Technologies',
            startDate: 'Jan 2021',
            endDate: 'Present',
            location: 'Bengaluru',
            bullets: [
              'Lead a team of 8 engineers building a payments super-app used by 10M+ users.',
              'Cut cold-start time by 45% through deferred initialisation and code splitting.',
              'Defined the BLoC-based architecture adopted across 6 product squads.',
            ],
          ),
          Experience(
            role: 'Senior Mobile Engineer',
            company: 'ShopVerse',
            startDate: 'Jun 2017',
            endDate: 'Dec 2020',
            location: 'Pune',
            bullets: [
              'Shipped the Flutter rewrite of the flagship shopping app (4.6★, 5M+ installs).',
              'Built an in-house design system with 60+ reusable components.',
            ],
          ),
        ],
        techSkills: [
          TechSkillGroup(
              category: 'Languages', skills: 'Dart, Kotlin, Swift, Java'),
          TechSkillGroup(
              category: 'Frameworks',
              skills: 'Flutter, Jetpack Compose, SwiftUI'),
          TechSkillGroup(
              category: 'Tools',
              skills: 'Firebase, Fastlane, GitHub Actions, Figma'),
          TechSkillGroup(category: 'PM', skills: 'Jira, Agile/Scrum, OKRs'),
        ],
        projects: [
          Project(
            name: 'ResumeKit Pro',
            role: 'Sole Developer',
            tech: 'Flutter, dart-pdf',
            description:
                'Offline-first resume builder with 10 switchable templates and on-device PDF export.',
            link: 'github.com/deepaksharma/resumekit',
          ),
          Project(
            name: 'TrackFit',
            role: 'Tech Lead',
            tech: 'Flutter, BLoC, Firebase',
            description:
                'Fitness tracking app with social challenges; 500K+ downloads on Play Store.',
          ),
        ],
        education: [
          Education(
            degree: 'B.Tech Computer Science',
            institution: 'NIT Surathkal',
            startYear: '2011',
            endYear: '2015',
            grade: '8.7 CGPA',
          ),
        ],
        personal: PersonalInfo(
          address: 'HSR Layout, Bengaluru, Karnataka 560102',
          dob: '12 May 1993',
          languages: 'Hindi, English, Kannada',
          hobbies: 'Trekking, chess, open-source',
        ),
        certificates: [
          Certificate(
            title: 'Flutter & Dart – The Complete Guide',
            issuer: 'Udemy',
            year: '2022',
          ),
          Certificate(
            title: 'Top 5% Flutter Contributor',
            issuer: 'Stack Overflow',
            year: '2023',
          ),
        ],
        patents: [
          Patent(
            title: 'Adaptive offline-sync protocol for mobile ledgers',
            number: 'IN 4521987',
            year: '2023',
          ),
        ],
      );
}
