import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/form_widgets.dart';
import 'package:template/model/biodata_data.dart';

/// 4-step marriage biodata wizard.
class BiodataFormPage extends StatefulWidget {
  const BiodataFormPage({super.key, required this.data});

  final BiodataData data;

  @override
  State<BiodataFormPage> createState() => _BiodataFormPageState();
}

class _BiodataFormPageState extends State<BiodataFormPage> {
  static const _titles = [
    'Personal Details',
    'Education & Career',
    'Family Details',
    'Contact & Expectations',
  ];

  int _step = 1;

  BiodataData get d => widget.data;

  void _next() {
    if (_step == 1 && d.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full name to continue.')),
      );
      return;
    }
    if (_step < 4) {
      setState(() => _step++);
    } else {
      Get.toNamed(RoutersConst.biodataPreview, arguments: d);
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_step - 1]),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Get.toNamed(RoutersConst.biodataPreview, arguments: d),
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
                    total: 4,
                    titles: _titles,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: switch (_step) {
                      1 => _step1(),
                      2 => _step2(),
                      3 => _step3(),
                      _ => _step4(),
                    },
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
                          child: Text(_step < 4 ? 'Next' : 'Preview Biodata'),
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

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Basic Details',
          subtitle: 'All fields optional except name — empty ones are hidden.',
        ),
        PhotoPickerField(
          photo: d.photo,
          onChanged: (bytes) => setState(() => d.photo = bytes),
        ),
        FormField2(
          label: 'Header Line / Invocation',
          value: d.invocation,
          hint: '|| Shree Ganeshaya Namah ||',
          onChanged: (v) => d.invocation = v,
        ),
        FormField2(
          label: 'Full Name',
          required: true,
          value: d.name,
          onChanged: (v) => d.name = v,
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Date of Birth',
                value: d.dob,
                hint: '14 February 1997',
                onChanged: (v) => d.dob = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Time of Birth',
                value: d.timeOfBirth,
                hint: '06:45 AM',
                onChanged: (v) => d.timeOfBirth = v,
              ),
            ),
          ],
        ),
        FormField2(
          label: 'Place of Birth',
          value: d.placeOfBirth,
          onChanged: (v) => d.placeOfBirth = v,
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Height',
                value: d.height,
                hint: "5' 4\"",
                onChanged: (v) => d.height = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Complexion',
                value: d.complexion,
                onChanged: (v) => d.complexion = v,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Blood Group',
                value: d.bloodGroup,
                onChanged: (v) => d.bloodGroup = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Marital Status',
                value: d.maritalStatus,
                hint: 'Never Married',
                onChanged: (v) => d.maritalStatus = v,
              ),
            ),
          ],
        ),
        FormField2(
          label: 'Diet',
          value: d.diet,
          hint: 'Vegetarian',
          onChanged: (v) => d.diet = v,
        ),
        FormField2(
          label: 'Hobbies / Interests',
          value: d.hobbies,
          onChanged: (v) => d.hobbies = v,
        ),
        const SectionHeader(title: 'Religion & Horoscope'),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Religion',
                value: d.religion,
                onChanged: (v) => d.religion = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Caste',
                value: d.caste,
                onChanged: (v) => d.caste = v,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Gotra',
                value: d.gotra,
                onChanged: (v) => d.gotra = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Manglik',
                value: d.manglik,
                hint: 'Yes / No',
                onChanged: (v) => d.manglik = v,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Rashi',
                value: d.rashi,
                onChanged: (v) => d.rashi = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Nakshatra',
                value: d.nakshatra,
                onChanged: (v) => d.nakshatra = v,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Education & Career'),
        FormField2(
          label: 'Education',
          value: d.education,
          hint: 'M.Sc. Computer Science, University of Rajasthan',
          onChanged: (v) => d.education = v,
        ),
        FormField2(
          label: 'Occupation',
          value: d.occupation,
          hint: 'Software Engineer',
          onChanged: (v) => d.occupation = v,
        ),
        FormField2(
          label: 'Company / Organisation',
          value: d.company,
          onChanged: (v) => d.company = v,
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Annual Income',
                value: d.income,
                hint: '₹14 LPA',
                onChanged: (v) => d.income = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Work Location',
                value: d.workLocation,
                onChanged: (v) => d.workLocation = v,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Family Details'),
        FormField2(
          label: "Father's Name",
          value: d.fatherName,
          onChanged: (v) => d.fatherName = v,
        ),
        FormField2(
          label: "Father's Occupation",
          value: d.fatherOccupation,
          onChanged: (v) => d.fatherOccupation = v,
        ),
        FormField2(
          label: "Mother's Name",
          value: d.motherName,
          onChanged: (v) => d.motherName = v,
        ),
        FormField2(
          label: "Mother's Occupation",
          value: d.motherOccupation,
          onChanged: (v) => d.motherOccupation = v,
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Brothers',
                value: d.brothers,
                hint: '1 (Elder, Married)',
                onChanged: (v) => d.brothers = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Sisters',
                value: d.sisters,
                onChanged: (v) => d.sisters = v,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FormField2(
                label: 'Family Type',
                value: d.familyType,
                hint: 'Nuclear / Joint',
                onChanged: (v) => d.familyType = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormField2(
                label: 'Family Values',
                value: d.familyValues,
                onChanged: (v) => d.familyValues = v,
              ),
            ),
          ],
        ),
        FormField2(
          label: 'Native Place',
          value: d.nativePlace,
          onChanged: (v) => d.nativePlace = v,
        ),
      ],
    );
  }

  Widget _step4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Partner Expectations',
          subtitle: 'A short paragraph about the kind of match you seek.',
        ),
        FormField2(
          label: 'Expectations',
          value: d.expectations,
          maxLines: 4,
          onChanged: (v) => d.expectations = v,
        ),
        const SectionHeader(title: 'Contact Details'),
        FormField2(
          label: 'Phone',
          value: d.phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => d.phone = v,
        ),
        FormField2(
          label: 'Email',
          value: d.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => d.email = v,
        ),
        FormField2(
          label: 'Address',
          value: d.address,
          maxLines: 2,
          onChanged: (v) => d.address = v,
        ),
      ],
    );
  }
}
