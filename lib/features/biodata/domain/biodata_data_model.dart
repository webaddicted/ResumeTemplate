import 'dart:typed_data';

/// Marriage biodata data model.
///
/// Same philosophy as [ResumeData]: plain optional strings, empty fields
/// and sections are hidden when rendered, content is fully decoupled from
/// the chosen template.
class BiodataData {
  BiodataData({
    this.invocation = '',
    this.name = '',
    this.dob = '',
    this.timeOfBirth = '',
    this.placeOfBirth = '',
    this.height = '',
    this.complexion = '',
    this.bloodGroup = '',
    this.religion = '',
    this.caste = '',
    this.gotra = '',
    this.rashi = '',
    this.nakshatra = '',
    this.manglik = '',
    this.maritalStatus = '',
    this.diet = '',
    this.hobbies = '',
    this.education = '',
    this.occupation = '',
    this.company = '',
    this.income = '',
    this.workLocation = '',
    this.fatherName = '',
    this.fatherOccupation = '',
    this.motherName = '',
    this.motherOccupation = '',
    this.brothers = '',
    this.sisters = '',
    this.familyType = '',
    this.familyValues = '',
    this.nativePlace = '',
    this.expectations = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.templateId = 'bio_maroon_heritage',
  });

  /// Optional headline line, e.g. "|| Shree Ganeshaya Namah ||".
  String invocation;

  // ---- Personal details ----
  String name;
  String dob;
  String timeOfBirth;
  String placeOfBirth;
  String height;
  String complexion;
  String bloodGroup;
  String religion;
  String caste;
  String gotra;
  String rashi;
  String nakshatra;
  String manglik;
  String maritalStatus;
  String diet;
  String hobbies;

  // ---- Education & career ----
  String education;
  String occupation;
  String company;
  String income;
  String workLocation;

  // ---- Family details ----
  String fatherName;
  String fatherOccupation;
  String motherName;
  String motherOccupation;
  String brothers;
  String sisters;
  String familyType;
  String familyValues;
  String nativePlace;

  // ---- Partner expectations ----
  String expectations;

  // ---- Contact ----
  String phone;
  String email;
  String address;

  String templateId;

  /// Optional profile photo (raw image bytes) — shown in the header
  /// medallion instead of initials.
  Uint8List? photo;

  /// (label, value) pairs per section — empty values are skipped, and a
  /// section with no pairs is hidden entirely.
  List<(String, String)> get personalRows => _rows([
        ('Date of Birth', dob),
        ('Height', height),
        ('Complexion', complexion),
        ('Blood Group', bloodGroup),
        ('Religion', religion),
        ('Caste', caste),
        ('Marital Status', maritalStatus),
        ('Diet', diet),
        ('Hobbies', hobbies),
      ]);

  List<(String, String)> get horoscopeRows => _rows([
        ('Time of Birth', timeOfBirth),
        ('Place of Birth', placeOfBirth),
        ('Rashi', rashi),
        ('Nakshatra', nakshatra),
        ('Gotra', gotra),
        ('Manglik', manglik),
      ]);

  List<(String, String)> get careerRows => _rows([
        ('Education', education),
        ('Occupation', occupation),
        ('Company', company),
        ('Annual Income', income),
        ('Work Location', workLocation),
      ]);

  List<(String, String)> get familyRows => _rows([
        ('Father', fatherName),
        ("Father's Occupation", fatherOccupation),
        ('Mother', motherName),
        ("Mother's Occupation", motherOccupation),
        ('Brothers', brothers),
        ('Sisters', sisters),
        ('Family Type', familyType),
        ('Family Values', familyValues),
        ('Native Place', nativePlace),
      ]);

  List<(String, String)> get contactRows => _rows([
        ('Phone', phone),
        ('Email', email),
        ('Address', address),
      ]);

  static List<(String, String)> _rows(List<(String, String)> all) =>
      [for (final r in all) if (r.$2.trim().isNotEmpty) r];

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// One-tap sample biodata.
  static BiodataData sample() => BiodataData(
        invocation: '|| Shree Ganeshaya Namah ||',
        name: 'Ananya Sharma',
        dob: '14 February 1997',
        timeOfBirth: '06:45 AM',
        placeOfBirth: 'Jaipur, Rajasthan',
        height: "5' 4\"",
        complexion: 'Fair',
        bloodGroup: 'B+',
        religion: 'Hindu',
        caste: 'Brahmin',
        gotra: 'Kashyap',
        rashi: 'Kumbh (Aquarius)',
        nakshatra: 'Shatabhisha',
        manglik: 'No',
        maritalStatus: 'Never Married',
        diet: 'Vegetarian',
        hobbies: 'Classical dance, reading, travelling',
        education: 'M.Sc. Computer Science, University of Rajasthan',
        occupation: 'Software Engineer',
        company: 'Infosys Ltd.',
        income: '₹14 LPA',
        workLocation: 'Bengaluru',
        fatherName: 'Shri Rajesh Sharma',
        fatherOccupation: 'Retired Bank Manager',
        motherName: 'Smt. Sunita Sharma',
        motherOccupation: 'Homemaker',
        brothers: '1 (Elder, Married)',
        sisters: 'None',
        familyType: 'Nuclear',
        familyValues: 'Traditional with modern outlook',
        nativePlace: 'Jaipur, Rajasthan',
        expectations:
            'Looking for a well-educated, family-oriented partner with a '
            'professional career, preferably settled in India, aged 27–32.',
        phone: '+91 98290 12345',
        email: 'sharma.family@example.com',
        address: '24, Malviya Nagar, Jaipur, Rajasthan 302017',
      );
}
