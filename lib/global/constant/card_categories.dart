import 'package:flutter/material.dart';

import '../../model/card_data.dart';

/// A selectable document category (e.g. "Marriage Invitation"), its rendering
/// family, the fields its form collects, and one-tap sample content.
class DocCategory {
  const DocCategory({
    required this.id,
    required this.label,
    required this.group,
    required this.family,
    required this.icon,
    required this.accent,
    required this.fields,
    required this.sample,
    this.usesPhoto = false,
    this.headline = '',
  });

  final String id;
  final String label;

  /// Section heading on the categories screen.
  final String group;
  final CardFamily family;
  final IconData icon;
  final Color accent;
  final List<CardFieldSpec> fields;

  /// Default headline shown on the card (e.g. "Wedding Invitation").
  final String headline;
  final bool usesPhoto;

  /// Sample field values for "⚡ Load Sample".
  final Map<String, String> sample;

  CardData newData(String templateId) => CardData(
        categoryId: id,
        templateId: templateId,
        usesPhoto: usesPhoto,
        values: {if (headline.isNotEmpty) 'headline': headline},
      );

  CardData sampleData(String templateId) => CardData(
        categoryId: id,
        templateId: templateId,
        usesPhoto: usesPhoto,
        values: {
          if (headline.isNotEmpty) 'headline': headline,
          ...sample,
        },
      );
}

/// ---- Reusable field bundles --------------------------------------------
const _whenWhere = [
  CardFieldSpec('date', 'Date', hint: 'e.g. Sunday, 14 Feb 2027'),
  CardFieldSpec('time', 'Time', hint: 'e.g. 7:00 PM onwards'),
  CardFieldSpec('venue', 'Venue', hint: 'Hall / place name'),
  CardFieldSpec('address', 'Address', hint: 'Full address', multiline: true),
  CardFieldSpec('rsvp', 'RSVP / Contact', hint: 'Phone or name'),
];

const _coupleFields = [
  CardFieldSpec('name1', 'First Name'),
  CardFieldSpec('name2', 'Second Name'),
  CardFieldSpec('host', 'Hosted By', hint: 'e.g. Together with their families'),
];

/// ---- The category registry ---------------------------------------------
class CardCategories {
  CardCategories._();

  static const _violet = Color(0xFF7C3AED);
  static const _rose = Color(0xFFC2185B);
  static const _gold = Color(0xFFA16207);
  static const _teal = Color(0xFF0E7490);
  static const _slate = Color(0xFF334155);
  static const _green = Color(0xFF1B7A4B);
  static const _amber = Color(0xFFB45309);
  static const _indigo = Color(0xFF3730A3);

  static final List<DocCategory> all = [
    // ---------------- Invitations ----------------
    DocCategory(
      id: 'inv_marriage',
      label: 'Marriage Invitation',
      group: 'Invitations',
      family: CardFamily.invitation,
      icon: Icons.favorite_rounded,
      accent: _rose,
      headline: 'Wedding Invitation',
      fields: [..._coupleFields, ..._whenWhere,
        CardFieldSpec('message', 'Message',
            hint: 'Request the pleasure of your company…', multiline: true)],
      sample: {
        'name1': 'Aarav',
        'name2': 'Ananya',
        'host': 'Together with their families',
        'date': 'Sunday, 14 February 2027',
        'time': '7:00 PM onwards',
        'venue': 'The Grand Palace',
        'address': 'MG Road, Jaipur, Rajasthan',
        'rsvp': '+91 98290 12345',
        'message':
            'Request the pleasure of your company to celebrate their wedding.',
      },
    ),
    DocCategory(
      id: 'inv_engagement',
      label: 'Engagement',
      group: 'Invitations',
      family: CardFamily.invitation,
      icon: Icons.diamond_rounded,
      accent: _violet,
      headline: 'Engagement Ceremony',
      fields: [..._coupleFields, ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true)],
      sample: {
        'name1': 'Rohan',
        'name2': 'Isha',
        'host': 'With the blessings of their families',
        'date': 'Saturday, 10 January 2027',
        'time': '6:30 PM',
        'venue': 'Rose Garden Banquet',
        'address': 'Pune, Maharashtra',
        'rsvp': 'Sharma Family · +91 99887 65432',
        'message': 'Join us to celebrate the engagement of',
      },
    ),
    DocCategory(
      id: 'inv_save_date',
      label: 'Save the Date',
      group: 'Invitations',
      family: CardFamily.invitation,
      icon: Icons.event_available_rounded,
      accent: _teal,
      headline: 'Save the Date',
      fields: [..._coupleFields,
        CardFieldSpec('date', 'Date'),
        CardFieldSpec('venue', 'City / Venue'),
        CardFieldSpec('message', 'Message', multiline: true)],
      sample: {
        'name1': 'Kabir',
        'name2': 'Meera',
        'host': 'are getting married',
        'date': '12 December 2027',
        'venue': 'Goa',
        'message': 'Formal invitation to follow.',
      },
    ),
    DocCategory(
      id: 'inv_wedding_program',
      label: 'Wedding Program',
      group: 'Invitations',
      family: CardFamily.invitation,
      icon: Icons.menu_book_rounded,
      accent: _gold,
      headline: 'Order of Events',
      fields: [..._coupleFields,
        CardFieldSpec('date', 'Date'),
        CardFieldSpec('venue', 'Venue'),
        CardFieldSpec('program', 'Programme',
            hint: 'One item per line, e.g. 4:00 PM — Baraat', multiline: true)],
      sample: {
        'name1': 'Aarav',
        'name2': 'Ananya',
        'host': 'Wedding Celebrations',
        'date': '14 February 2027',
        'venue': 'The Grand Palace',
        'program':
            '4:00 PM — Baraat\n5:30 PM — Varmala\n7:00 PM — Pheras\n9:00 PM — Dinner',
      },
    ),
    DocCategory(
      id: 'inv_demise',
      label: 'Funeral / Demise',
      group: 'Invitations',
      family: CardFamily.invitation,
      icon: Icons.local_florist_rounded,
      accent: _slate,
      headline: 'In Loving Memory',
      usesPhoto: true,
      fields: [
        CardFieldSpec('name1', 'Name of the Departed'),
        CardFieldSpec('subtitle', 'Dates', hint: 'e.g. 1945 – 2027'),
        CardFieldSpec('message', 'Message', multiline: true),
        CardFieldSpec('date', 'Prayer Meeting Date'),
        CardFieldSpec('time', 'Time'),
        CardFieldSpec('venue', 'Venue'),
        CardFieldSpec('host', 'From', hint: 'Family name'),
      ],
      sample: {
        'name1': 'Shri Ramesh Kumar',
        'subtitle': '1945 – 2027',
        'message':
            'With profound grief we inform the sad demise of our beloved. '
            'A prayer meeting will be held to pay homage.',
        'date': 'Friday, 20 February 2027',
        'time': '4:00 PM to 5:00 PM',
        'venue': 'Community Hall, Sector 12',
        'host': 'The Kumar Family',
      },
    ),
    DocCategory(
      id: 'inv_birthday',
      label: 'Birthday Invitation',
      group: 'Events',
      family: CardFamily.invitation,
      icon: Icons.cake_rounded,
      accent: _rose,
      headline: "You're Invited!",
      fields: [
        CardFieldSpec('name1', 'Name'),
        CardFieldSpec('subtitle', 'Turning', hint: 'e.g. Turning 5!'),
        ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true),
      ],
      sample: {
        'name1': 'Aarohi',
        'subtitle': 'Turning 5!',
        'date': 'Saturday, 3 April 2027',
        'time': '4:00 PM',
        'venue': 'FunZone Play Arena',
        'address': 'Koramangala, Bengaluru',
        'rsvp': 'Mom · +91 98765 43210',
        'message': 'Join us for cake, games and lots of fun!',
      },
    ),
    DocCategory(
      id: 'inv_anniversary',
      label: 'Anniversary Invitation',
      group: 'Events',
      family: CardFamily.invitation,
      icon: Icons.favorite_border_rounded,
      accent: _gold,
      headline: 'Anniversary Celebration',
      fields: [..._coupleFields,
        CardFieldSpec('subtitle', 'Milestone', hint: 'e.g. 25th Anniversary'),
        ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true)],
      sample: {
        'name1': 'Rajesh',
        'name2': 'Sunita',
        'host': 'request your presence',
        'subtitle': '25th Wedding Anniversary',
        'date': 'Sunday, 5 June 2027',
        'time': '7:30 PM',
        'venue': 'Silver Oak Banquet',
        'address': 'Jaipur',
        'rsvp': '+91 99887 11223',
        'message': 'Celebrate 25 wonderful years with us.',
      },
    ),
    DocCategory(
      id: 'inv_baby_shower',
      label: 'Baby Shower',
      group: 'Events',
      family: CardFamily.invitation,
      icon: Icons.child_friendly_rounded,
      accent: _teal,
      headline: 'Baby Shower',
      fields: [
        CardFieldSpec('name1', 'Parents / Mom-to-be'),
        CardFieldSpec('subtitle', 'Tagline', hint: 'e.g. A little one is on the way'),
        ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true),
      ],
      sample: {
        'name1': 'Priya & Arjun',
        'subtitle': 'A little one is on the way!',
        'date': 'Sunday, 18 July 2027',
        'time': '11:00 AM',
        'venue': 'Garden Terrace',
        'address': 'Bengaluru',
        'rsvp': '+91 90000 12345',
        'message': 'Join us to shower the parents-to-be with love.',
      },
    ),
    DocCategory(
      id: 'inv_housewarming',
      label: 'Housewarming',
      group: 'Events',
      family: CardFamily.invitation,
      icon: Icons.home_rounded,
      accent: _green,
      headline: 'Griha Pravesh',
      fields: [
        CardFieldSpec('name1', 'Family / Host'),
        CardFieldSpec('subtitle', 'Tagline', hint: 'e.g. Our new home'),
        ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true),
      ],
      sample: {
        'name1': 'The Mehta Family',
        'subtitle': 'cordially invites you to our new home',
        'date': 'Saturday, 8 May 2027',
        'time': '10:30 AM — Puja',
        'venue': 'Villa 24, Green Meadows',
        'address': 'Whitefield, Bengaluru',
        'rsvp': '+91 98450 67890',
        'message': 'Your blessings will make our new beginning special.',
      },
    ),
    DocCategory(
      id: 'inv_retirement',
      label: 'Retirement',
      group: 'Events',
      family: CardFamily.invitation,
      icon: Icons.workspace_premium_rounded,
      accent: _indigo,
      headline: 'Retirement Celebration',
      usesPhoto: true,
      fields: [
        CardFieldSpec('name1', 'Name'),
        CardFieldSpec('subtitle', 'Role / Years', hint: 'e.g. After 35 years of service'),
        ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true),
      ],
      sample: {
        'name1': 'Mr. Suresh Iyer',
        'subtitle': 'After 35 years of dedicated service',
        'date': 'Friday, 30 April 2027',
        'time': '6:00 PM',
        'venue': 'Hotel Grand Vista',
        'address': 'Chennai',
        'rsvp': 'HR Team · +91 44 1234 5678',
        'message': 'Join us to honour a remarkable career.',
      },
    ),
    DocCategory(
      id: 'inv_farewell',
      label: 'Farewell',
      group: 'Events',
      family: CardFamily.invitation,
      icon: Icons.waving_hand_rounded,
      accent: _amber,
      headline: 'Farewell',
      fields: [
        CardFieldSpec('name1', 'Name / Group'),
        CardFieldSpec('subtitle', 'Tagline', hint: 'e.g. Wishing you the best'),
        ..._whenWhere,
        CardFieldSpec('message', 'Message', multiline: true),
      ],
      sample: {
        'name1': 'Ananya Verma',
        'subtitle': 'Wishing you the very best ahead',
        'date': 'Thursday, 25 March 2027',
        'time': '5:00 PM',
        'venue': 'Conference Room A',
        'address': 'TechPark, Pune',
        'rsvp': 'Team Mobile',
        'message': 'Join us to bid a warm farewell.',
      },
    ),
    // ---------------- Event pass ----------------
    DocCategory(
      id: 'event_pass',
      label: 'Event Pass',
      group: 'Events',
      family: CardFamily.eventPass,
      icon: Icons.confirmation_number_rounded,
      accent: _violet,
      headline: 'EVENT PASS',
      fields: [
        CardFieldSpec('event', 'Event Name'),
        CardFieldSpec('name1', 'Attendee Name'),
        CardFieldSpec('passType', 'Pass Type', hint: 'e.g. VIP / General'),
        CardFieldSpec('date', 'Date'),
        CardFieldSpec('time', 'Time'),
        CardFieldSpec('venue', 'Venue'),
        CardFieldSpec('seat', 'Seat / Gate', hint: 'e.g. Gate 3 · Seat A12'),
        CardFieldSpec('code', 'Pass ID', hint: 'e.g. PASS-2027-0042'),
      ],
      sample: {
        'event': 'TechFront Conference 2027',
        'name1': 'Deepak Sharma',
        'passType': 'VIP Access',
        'date': '22 August 2027',
        'time': '9:00 AM',
        'venue': 'Bombay Convention Centre',
        'seat': 'Gate 3 · Seat A12',
        'code': 'PASS-2027-0042',
      },
    ),
    // ---------------- Business ----------------
    DocCategory(
      id: 'business_card',
      label: 'Business Card',
      group: 'Business',
      family: CardFamily.businessCard,
      icon: Icons.badge_rounded,
      accent: _slate,
      fields: [
        CardFieldSpec('name1', 'Full Name'),
        CardFieldSpec('designation', 'Designation'),
        CardFieldSpec('company', 'Company'),
        CardFieldSpec('phone', 'Phone'),
        CardFieldSpec('email', 'Email'),
        CardFieldSpec('website', 'Website'),
        CardFieldSpec('address', 'Address', multiline: true),
      ],
      sample: {
        'name1': 'Deepak Sharma',
        'designation': 'Technical Lead — Mobile',
        'company': 'FinPay Technologies',
        'phone': '+91 98765 43210',
        'email': 'deepak@finpay.com',
        'website': 'finpay.com',
        'address': 'HSR Layout, Bengaluru',
      },
    ),
    DocCategory(
      id: 'visiting_card',
      label: 'Visiting Card',
      group: 'Business',
      family: CardFamily.businessCard,
      icon: Icons.contact_mail_rounded,
      accent: _teal,
      fields: [
        CardFieldSpec('name1', 'Full Name'),
        CardFieldSpec('designation', 'Profession / Title'),
        CardFieldSpec('company', 'Business Name'),
        CardFieldSpec('phone', 'Phone'),
        CardFieldSpec('email', 'Email'),
        CardFieldSpec('website', 'Website / Social'),
        CardFieldSpec('address', 'Address', multiline: true),
      ],
      sample: {
        'name1': 'Ananya Rao',
        'designation': 'Interior Designer',
        'company': 'Studio Aesthetica',
        'phone': '+91 99887 65432',
        'email': 'hello@aesthetica.in',
        'website': '@studio.aesthetica',
        'address': 'Indiranagar, Bengaluru',
      },
    ),
    // ---------------- Profiles ----------------
    DocCategory(
      id: 'personal_profile',
      label: 'Personal Profile',
      group: 'Profiles',
      family: CardFamily.profile,
      icon: Icons.person_rounded,
      accent: _violet,
      usesPhoto: true,
      fields: [
        CardFieldSpec('name1', 'Full Name'),
        CardFieldSpec('subtitle', 'Headline', hint: 'e.g. Product Designer'),
        CardFieldSpec('about', 'About', multiline: true),
        CardFieldSpec('phone', 'Phone'),
        CardFieldSpec('email', 'Email'),
        CardFieldSpec('website', 'Website'),
        CardFieldSpec('location', 'Location'),
        CardFieldSpec('interests', 'Interests', hint: 'Comma separated'),
      ],
      sample: {
        'name1': 'Ananya Rao',
        'subtitle': 'Product Designer & Illustrator',
        'about':
            'Designer with 6 years crafting delightful digital products. '
            'I love clean interfaces, type, and a good cup of coffee.',
        'phone': '+91 99887 65432',
        'email': 'ananya@example.com',
        'website': 'ananya.design',
        'location': 'Bengaluru, India',
        'interests': 'Illustration, travel, photography',
      },
    ),
    DocCategory(
      id: 'student_profile',
      label: 'Student Profile',
      group: 'Profiles',
      family: CardFamily.profile,
      icon: Icons.school_rounded,
      accent: _indigo,
      usesPhoto: true,
      fields: [
        CardFieldSpec('name1', 'Full Name'),
        CardFieldSpec('subtitle', 'Course / Class', hint: 'e.g. B.Tech CSE, 3rd Year'),
        CardFieldSpec('about', 'About Me', multiline: true),
        CardFieldSpec('school', 'School / College'),
        CardFieldSpec('roll', 'Roll No. / ID'),
        CardFieldSpec('email', 'Email'),
        CardFieldSpec('phone', 'Phone'),
        CardFieldSpec('interests', 'Interests / Skills', hint: 'Comma separated'),
      ],
      sample: {
        'name1': 'Rahul Verma',
        'subtitle': 'B.Tech Computer Science · 3rd Year',
        'about':
            'Enthusiastic CS student passionate about app development and '
            'open-source. Looking for summer internship opportunities.',
        'school': 'NIT Surathkal',
        'roll': '21CS045',
        'email': 'rahul.verma@nitk.edu.in',
        'phone': '+91 90000 11223',
        'interests': 'Flutter, competitive coding, chess',
      },
    ),
    DocCategory(
      id: 'social_bio',
      label: 'Social Media Bio',
      group: 'Profiles',
      family: CardFamily.profile,
      icon: Icons.alternate_email_rounded,
      accent: _rose,
      usesPhoto: true,
      fields: [
        CardFieldSpec('name1', 'Display Name'),
        CardFieldSpec('subtitle', 'Handle', hint: 'e.g. @ananya.creates'),
        CardFieldSpec('about', 'Bio', hint: 'Short and punchy', multiline: true),
        CardFieldSpec('website', 'Link', hint: 'e.g. linktr.ee/ananya'),
        CardFieldSpec('interests', 'Tags', hint: 'e.g. #design #travel #coffee'),
      ],
      sample: {
        'name1': 'Ananya',
        'subtitle': '@ananya.creates',
        'about':
            'Designer · illustrator · storyteller ✨\nMaking the internet a '
            'prettier place, one pixel at a time.',
        'website': 'linktr.ee/ananya',
        'interests': '#design #illustration #coffee #travel',
      },
    ),
  ];

  static DocCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);

  /// Categories grouped in display order for the categories screen.
  static Map<String, List<DocCategory>> get grouped {
    final out = <String, List<DocCategory>>{};
    for (final c in all) {
      out.putIfAbsent(c.group, () => []).add(c);
    }
    return out;
  }
}
