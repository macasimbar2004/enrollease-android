// ignore_for_file: unnecessary_string_interpolations

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:enrollease/appwrite.dart';
import 'package:enrollease/dev.dart';
import 'package:enrollease/model/civil_status_enum.dart';
import 'package:enrollease/model/enrollment_form_model.dart';
import 'package:enrollease/model/enrollment_status_enum.dart';
import 'package:enrollease/model/gender_enum.dart';
import 'package:enrollease/model/grade_enum.dart';
import 'package:enrollease/states_management/account_data_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/custom_loading_dialog.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_card.dart';
import 'package:enrollease/widgets/custom_confirmation_dialog.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:enrollease/widgets/custom_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

enum CredentialData {
  form138,
  coc,
  goodMoral,
  birthCert,
  sigOverName,
}

extension CredString on CredentialData {
  String displayName() {
    switch (this) {
      case CredentialData.form138:
        return 'Card (Form 138)';
      case CredentialData.coc:
        return 'Cert. of Completion (Photocopy)';
      case CredentialData.goodMoral:
        return 'Good Moral';
      case CredentialData.birthCert:
        return 'NSO Birth Cert. (Photocopy)';
      case CredentialData.sigOverName:
        return 'Signature Over Printed Name';
    }
  }
}

class EnrollFormPage extends StatefulWidget {
  const EnrollFormPage({super.key});

  @override
  State<EnrollFormPage> createState() => _EnrollFormPageState();
}

class _EnrollFormPageState extends State<EnrollFormPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseAuthProvider auth = FirebaseAuthProvider();
  late final StreamSubscription enrollNo;
  String? regNo = '';
  Grade? enrollingGrade;
  Gender? gender;
  bool? unpaidBill;
  CivilStatus? cStatus;
  bool? ipOrIcc;

  Map<CredentialData, PlatformFile?> credentialData = {
    for (final e in CredentialData.values) e: null,
  };

  Map<CredentialData, bool> credentialDataLoading = {
    for (final e in CredentialData.values) e: false,
  };

  final addressController = TextEditingController();
  final motherTongueController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final ageController = TextEditingController();
  final cellNoController = TextEditingController(text: '+63');
  final emailController = TextEditingController();
  final lastSchoolAttendedController = TextEditingController();
  // final additionalInfoController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lrnController = TextEditingController();
  final placeOfBirthController = TextEditingController();
  final religionController = TextEditingController();
  final sdaBaptismDateController = TextEditingController();
  final unpaidBillController = TextEditingController();
  final fathersFirstNameController = TextEditingController();
  final fathersMiddleNameController = TextEditingController();
  final fathersLastNameController = TextEditingController();
  final fathersOccController = TextEditingController();
  final mothersFirstNameController = TextEditingController();
  final mothersMiddleNameController = TextEditingController();
  final mothersLastNameController = TextEditingController();
  final mothersOccController = TextEditingController();
  final additionalInfoController = TextEditingController();

  void _ensurePrefix() {
    const prefix = '+63';
    if (!cellNoController.text.startsWith(prefix)) {
      cellNoController.text = prefix;
      cellNoController.selection = TextSelection.fromPosition(
        TextPosition(offset: cellNoController.text.length),
      );
    }
  }

  Future<void> handleEnrollmentFormSave(BuildContext context) async {
    final providerData = Provider.of<AccountDataController>(context, listen: false).currentUser;

    try {
      if (!context.mounted) return;
      showLoadingDialog(context, 'Submitting form...');
      final ids = {};
      // upload each credential, get the link id from each one.
      for (final entry in credentialData.entries) {
        ids.addAll({entry.key: await uploadData(entry.key, entry.value!)});
      }
      dPrint(ids.toString());
      final lrn = lrnController.text.trim();
      final sdaBaptismDate = sdaBaptismDateController.text.trim();
      final unpaidBill = unpaidBillController.text.trim();
      final middleName = middleNameController.text.trim();
      final fathersMiddleName = fathersMiddleNameController.text.trim();
      final mothersMiddleName = mothersMiddleNameController.text.trim();
      final fathersOcc = fathersOccController.text.trim();
      final mothersOcc = mothersOccController.text.trim();
      final lastSchoolAttended = lastSchoolAttendedController.text.trim();
      final enrollmentForm = EnrollmentFormModel(
        regNo: regNo!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        middleName: middleName,
        lrn: lrn,
        enrollingGrade: enrollingGrade!,
        gender: gender!,
        age: int.parse(ageController.text.trim()),
        dateOfBirth: dateOfBirthController.text.trim(),
        placeOfBirth: placeOfBirthController.text.trim(),
        religion: religionController.text.trim(),
        sdaBaptismDate: sdaBaptismDate,
        cellno: int.parse(cellNoController.text),
        lastSchoolAttended: lastSchoolAttended,
        unpaidBill: unpaidBill.isNotEmpty ? double.parse(unpaidBillController.text.trim()) : 0,
        parentsUserId: providerData!.uid,
        fathersFirstName: fathersFirstNameController.text.trim(),
        fathersMiddleName: fathersMiddleName,
        fathersLastName: fathersLastNameController.text.trim(),
        fathersOcc: fathersOcc,
        mothersFirstName: mothersFirstNameController.text.trim(),
        mothersMiddleName: mothersMiddleName,
        mothersLastName: mothersLastNameController.text.trim(),
        mothersOcc: mothersOcc,
        form138Link: ids[CredentialData.form138],
        cocLink: ids[CredentialData.coc],
        birthCertLink: ids[CredentialData.birthCert],
        goodMoralLink: ids[CredentialData.goodMoral],
        sigOverNameLink: ids[CredentialData.sigOverName],
        additionalInfo: additionalInfoController.text.trim(),
        status: EnrollmentStatus.pending,
        timestamp: DateTime.now(),
        address: addressController.text.trim(),
        motherTongue: motherTongueController.text.trim(),
        civilStatus: cStatus!,
        ipOrIcc: ipOrIcc!,
      );

      await auth.saveEnrollmentFormData(enrollmentForm);
      if (context.mounted) {
        Navigator.pop(context);
        DelightfulToast.showSuccess(context, 'Success', 'Enrollment form submitted');
        Nav.pop(context);
      }
    } catch (e) {
      dPrint('Error: $e');
      if (context.mounted) {
        Navigator.pop(context);
        DelightfulToast.showError(context, 'Error', 'Enrollment form failed to submitted.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Start the stream subscription when the widget is initialized
    enrollNo = auth.generateNewEnrollmentNo().listen((newRegNo) {
      if (!mounted) return;
      setState(() {
        regNo = newRegNo; // Update the registration number when the stream emits a new value
      });
    });
    cellNoController.addListener(_ensurePrefix);
  }

  @override
  void dispose() {
    super.dispose();
    enrollNo.cancel();
    cellNoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        title: Text(
          'ENROLLMENT FORM',
          style: CustomTextStyles.inknutAntiquaBlack(fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Nav.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: formKey,
                    child: _buildForm(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
              child: _buildAction(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return CustomCard(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registration No: $regNo', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const Divider(
              color: Colors.black,
            ),
            const Text('PUPIL INFORMATION:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              firstNameController,
              'First Name',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            _buildTextField(
              middleNameController,
              'Middle Name (leave blank if none)',
            ),
            _buildTextField(
              lastNameController,
              'Last Name',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            const SizedBox(height: 10),
            _buildDateAndAgeFields(
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              placeOfBirthController,
              'Place of Birth',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            const SizedBox(height: 10),
            _buildGenderSelection(),
            const SizedBox(height: 10),
            _buildTextField(
              religionController,
              'Religion',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            const Text('If baptized SDA, when?'),
            const SizedBox(height: 10),
            _buildSDABapField(),
            const SizedBox(height: 10),
            _buildIpOrIcc(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Civil Status:'),
                Flexible(
                  child: _buildDropdown<CivilStatus>(
                      value: cStatus,
                      items: CivilStatus.values,
                      hint: '<Select status>',
                      onChanged: (value) {
                        setState(() {
                          cStatus = value;
                        });
                      },
                      errorText: 'Please select an option.'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              motherTongueController,
              'Mother Tongue',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            const Text('FATHER\'S INFORMATION:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              fathersFirstNameController,
              'First Name',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            _buildTextField(
              fathersMiddleNameController,
              'Middle Name (leave blank if none)',
            ),
            _buildTextField(
              fathersLastNameController,
              'Last Name',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            _buildTextField(
              fathersOccController,
              'Occupation (leave blank if none)',
            ),
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            const Text('MOTHER\'S INFORMATION:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              mothersFirstNameController,
              'First Name',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            _buildTextField(
              mothersMiddleNameController,
              'Middle Name (leave blank if none)',
            ),
            _buildTextField(
              mothersLastNameController,
              'Last Name',
              validator: (value) => TextValidator.simpleValidator(value),
            ),
            _buildTextField(
              mothersOccController,
              'Occupation (leave blank if none)',
            ),
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            const Text('CONTACT INFORMATION:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              cellNoController,
              'Phone Number',
              maxLength: 13,
              isContactNumber: true,
              validator: (value) => TextValidator.validateContact(value),
            ),
            _buildTextField(
              emailController,
              'Email',
              validator: (value) => TextValidator.validateEmail(value!.trim()),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            const Text('ACADEMIC INFORMATION:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              lastSchoolAttendedController,
              'Previous School (leave blank if none)',
              maxLength: 100,
            ),
            _buildTextField(
              lrnController,
              'LRN (leave blank if no previous school)',
              maxLength: 30,
              digitsOnly: true,
            ),
            _buildUnpaidBillSelection(unpaidBill),
            if (unpaidBill != null && unpaidBill == true)
              _buildTextField(
                unpaidBillController,
                'How much?',
                maxLength: 100,
                validator: (value) => TextValidator.simpleValidator(value),
              ),
            Row(
              children: [
                const Text('Grade to Enroll:'),
                Flexible(
                  child: _buildDropdown<Grade>(
                      value: enrollingGrade,
                      items: Grade.values,
                      hint: '<Select grade>',
                      onChanged: (value) {
                        setState(() {
                          enrollingGrade = value;
                        });
                      },
                      errorText: 'Please select grade.'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.black,
            ),
            const Text('VALID CREDENTIALS:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Only image or pdf files are allowed.'),
            const SizedBox(height: 10),
            ...credentialData.entries.map((e) => _buildCredBtn(e.key, e.value)),
            const SizedBox(height: 10),
            const Text('Additional Info:'),
            const SizedBox(height: 5),
            _buildTextField(additionalInfoController, 'Add comments', showAsLabel: false),
          ],
        ),
      ),
    );
  }

  void toggleCredBtnLoading(CredentialData type) => setState(() {
        credentialDataLoading[type] = !credentialDataLoading[type]!;
      });

  Widget _buildCredBtn(CredentialData type, PlatformFile? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomCard(
        color: Colors.blueGrey.shade800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${type.displayName()}'),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: credentialDataLoading[type] == true
                          ? Colors.grey
                          : data == null
                              ? Colors.amber.shade300
                              : Colors.green.shade300),
                  onPressed: () async {
                    if (credentialDataLoading[type]!) return;
                    toggleCredBtnLoading(type);
                    await saveFileData(type);
                    toggleCredBtnLoading(type);
                  },
                  child: Row(
                    children: [
                      Icon(data == null ? Icons.file_copy : Icons.check_circle),
                      const SizedBox(width: 5),
                      Text(data == null ? 'Choose' : data.name),
                    ],
                  ),
                ),
                // Text(data == null ? 'No file selected.' : data.name),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> saveFileData(CredentialData type) async {
    FilePickerResult? img = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
        'png',
        'gif',
        'pdf',
      ],
    );
    if (img != null) {
      PlatformFile? file = img.files.first;
      if (file.bytes == null) {
        return 'The file you provided is corrupted.';
      }
      if (file.path == null) {
        return 'The path to the file cannot be found.';
      }
      setState(() {
        credentialData[type] = file;
      });
    }
    return null;
  }

  Future<String?> uploadData(CredentialData type, PlatformFile file) async {
    final mimeType = lookupMimeType(file.path!);
    dPrint(mimeType);
    final fileID = '$regNo-${type.name}';
    try {
      final response = await storage.createFile(
        bucketId: bucketIDCredentialData, // Replace with your bucket ID
        fileId: fileID, // files with same ID will get overwrited, which is needed if the user is asked to change it later
        file: InputFile.fromBytes(
          bytes: file.bytes!,
          filename: '$regNo-${type.name}',
          contentType: mimeType,
        ),
      );
      dPrint('File uploaded: ${response.$id}');
      return fileID;
    } catch (e) {
      dPrint('Error uploading file: $e');
      return null;
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool digitsOnly = false,
    bool? isContactNumber,
    String? Function(String?)? validator,
    int? maxLength = 50,
    bool showAsLabel = true,
  }) {
    return CustomTextFormField(
      toShow: false,
      controller: controller,
      hintText: hintText,
      toShowLabelText: showAsLabel,
      toShowIcon: false,
      toShowPrefixIcon: false,
      digitsOnly: digitsOnly,
      isPhoneNumber: isContactNumber,
      validator: validator,
      maxLength: maxLength,
    );
  }

  Widget _buildSDABapField({String? Function(String?)? validator}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomTextFormField(
            //not tappable
            toShow: false,
            controller: sdaBaptismDateController,
            hintText: 'Date of Baptism (if SDA)',
            isDateTime: true,
            iconDataSuffix: Icons.calendar_month,
            toShowIcon: true,
            toShowPrefixIcon: false,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndAgeFields({String? Function(String?)? validator}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomTextFormField(
            //not tappable
            toShow: false,
            controller: dateOfBirthController,
            ageController: ageController,
            hintText: 'Date of Birth',
            isDateTime: true,
            iconDataSuffix: Icons.calendar_month,
            toShowIcon: true,
            toShowPrefixIcon: false,
            validator: validator,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: CustomTextFormField(
            toShow: false,
            controller: ageController,
            hintText: 'Age',
            isDateTime: true,
            leftPadding: 20,
            toShowIcon: false,
            toShowPrefixIcon: false,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildUnpaidBillSelection(bool? selection) {
    return FormField<bool>(
      validator: (value) {
        if (value == null) {
          return 'Select an option.';
        }
        return null;
      },
      builder: (field) {
        return Column(
          children: [
            Row(
              children: [
                const Text('Do you have unpaid bill?'),
                Radio(
                  value: true,
                  groupValue: field.value,
                  onChanged: (newValue) {
                    field.didChange(newValue);
                    setState(() {
                      unpaidBill = newValue!;
                    });
                  },
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (field.hasError) {
                      return Colors.red; // Red color when there is an error
                    }
                    return Colors.black54;
                  }),
                  // activeColor: Colors.black,
                ),
                const Text('Yes'),
                Radio(
                  value: false,
                  groupValue: field.value,
                  onChanged: (newValue) {
                    field.didChange(newValue);
                    setState(() {
                      unpaidBill = newValue!;
                    });
                  },
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (field.hasError) {
                      return Colors.red; // Red color when there is an error
                    }
                    return Colors.black54;
                  }),
                  // activeColor: Colors.black,
                ),
                const Text('No')
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  // Widget _buildenrollingGradeSelection(Enum? selection) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       const Text('Grade Level Applying For: '),
  //       ...Grade.values.map((value) => buildGenderRadio(value, selection)),
  //     ],
  //   );
  // }

  Widget _buildGenderSelection() {
    return FormField<Gender>(
      validator: (value) {
        if (value == null) {
          return 'Select a gender.';
        }
        return null;
      },
      builder: (field) {
        return Row(
          children: [
            const Text('Gender: '),
            ...Gender.values.map(
              (value) => buildGenderRadio(value, field),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIpOrIcc() {
    return FormField<bool>(
      validator: (value) {
        if (value == null) {
          return 'Select an option.';
        }
        return null;
      },
      builder: (field) {
        return Row(
          children: [
            const Text('Are you Ip/Icc? '),
            buildIpOrIccRadio(true, field),
            buildIpOrIccRadio(false, field),
          ],
        );
      },
    );
  }

  Widget buildIpOrIccRadio(bool value, FormFieldState<bool> field) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: field.value,
          onChanged: (newValue) {
            field.didChange(newValue);
            setState(() {
              ipOrIcc = newValue!;
            });
          },
          // activeColor: Colors.black,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (field.hasError) {
              return Colors.red; // Red color when there is an error
            }
            return Colors.black54;
          }),
        ),
        Text(value ? 'Yes' : 'No'),
      ],
    );
  }

  Widget buildGenderRadio(Gender value, FormFieldState<Gender> field) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: field.value,
          onChanged: (newValue) {
            field.didChange(newValue);
            setState(() {
              gender = newValue!;
            });
          },
          // activeColor: Colors.black,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (field.hasError) {
              return Colors.red; // Red color when there is an error
            }
            return Colors.black54;
          }),
        ),
        Text('${value.name[0].toUpperCase()}${value.name.substring(1)}'),
      ],
    );
  }

  // Widget _buildAddressDropdowns() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('Select Province:'),
  //       _buildDropdown<String>(
  //         value: selectedProvince,
  //         items: provinces.map((province) => province.name).toList(),
  //         hint: 'Choose a province',
  //         onChanged: (newValue) {
  //           setState(() {
  //             selectedProvince = newValue;
  //             selectedCity = null;
  //             selectedBarangay = null;
  //             zipCode = null;
  //           });
  //         },
  //       ),
  //       const SizedBox(height: 20),
  //       const Text('Select City:'),
  //       _buildDropdown<String>(
  //         value: selectedCity,
  //         items: selectedProvince != null ? provinces.firstWhere((p) => p.name == selectedProvince).cities.map((city) => city.name).toList() : [],
  //         hint: 'Choose a city',
  //         onChanged: (newValue) {
  //           setState(() {
  //             selectedCity = newValue;
  //             selectedBarangay = null;
  //             zipCode = null;
  //           });
  //         },
  //       ),
  //       const SizedBox(height: 20),
  //       const Text('Select Barangay:'),
  //       _buildDropdown<String>(
  //         value: selectedBarangay,
  //         items: selectedCity != null ? provinces.firstWhere((p) => p.name == selectedProvince).cities.firstWhere((c) => c.name == selectedCity).barangays.map((barangay) => barangay.name).toList() : [],
  //         hint: 'Choose a barangay',
  //         onChanged: (newValue) {
  //           setState(() {
  //             selectedBarangay = newValue;
  //             zipCode = provinces.firstWhere((p) => p.name == selectedProvince).cities.firstWhere((c) => c.name == selectedCity).zipCode;
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildAction(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: CustomBtn(
              vertical: 3,
              colorBg: Colors.red.shade400,
              colorTxt: Colors.white,
              btnIcon: Icons.clear,
              btnTxt: 'Clear',
              btnFontWeight: FontWeight.normal,
              txtSize: 14,
              onTap: () async {
                final confirmation = await showConfirmationDialog(
                  context: context,
                  title: 'Clear All',
                  message: 'Are you sure to clear all fields?',
                  confirmText: 'Yes',
                  cancelText: 'No',
                );
                if (confirmation != null && confirmation) {
                  if (!context.mounted) return;
                  Nav.pushReplace(context, const EnrollFormPage());
                  // setState(() {
                  //   // Clear image paths or any other lists
                  //   credentialData.forEach((k, v) => v == null);

                  //   // Clear all text fields
                  //   firstNameController.clear();
                  //   lastNameController.clear();
                  //   middleNameController.clear();
                  //   dateOfBirthController.clear();
                  //   ageController.clear();

                  //   religionController.clear();
                  //   dateOfBirthController.clear();

                  //   fathersFirstNameController.clear();
                  //   fathersLastNameController.clear();
                  //   fathersMiddleNameController.clear();
                  //   fathersOccController.clear();
                  //   mothersFirstNameController.clear();
                  //   mothersLastNameController.clear();
                  //   mothersMiddleNameController.clear();
                  //   mothersOccController.clear();
                  //   sdaBaptismDateController.clear();

                  //   cellNoController.clear();
                  //   emailController.clear();
                  //   lastSchoolAttendedController.clear();
                  //   additionalInfoController.clear();

                  //   // Reset selection variables to null
                  //   gender = null;
                  //   enrollingGrade = null;
                  //   unpaidBill = null;
                  //   unpaidBillController.clear();
                  // });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomBtn(
            vertical: 3,
            colorBg: CustomColors.appBarColor,
            colorTxt: Colors.white,
            btnIcon: Icons.send,
            btnTxt: 'Submit',
            btnFontWeight: FontWeight.normal,
            txtSize: 14,
            onTap: () async {
              if (formKey.currentState!.validate()) {
                for (final data in credentialData.entries) {
                  if (data.value == null) {
                    DelightfulToast.showError(context, 'Missing credentials', 'Please provide all required credentials!');
                    return;
                  }
                }
                if (lastSchoolAttendedController.text.trim().isNotEmpty && lrnController.text.trim().isEmpty) {
                  DelightfulToast.showError(context, 'Error', 'If pupil has previous school, you must provide LRN!');
                  return;
                }
                // TODO: occupations are optional because the guardian may be the one signing up, or the child's parents may be decreased
                await handleEnrollmentFormSave(context);
              } else {
                DelightfulToast.showError(context, 'Error', 'Please provide all fields!');
                dPrint('Form is invalid, show errors.');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
    required String? errorText,
  }) {
    return DropdownButtonFormField<T>(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item is Grade ? (item as Grade).formalLongString() : (item as Enum).name),
            ),
          )
          .toList(),
      onChanged: onChanged,
      hint: Text(hint),
      validator: (value) {
        if (value == null) {
          return errorText ?? 'Please select an option';
        }
        return null; // No error
      },
    );
  }
}
