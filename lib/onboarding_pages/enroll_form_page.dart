import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/data/address_data.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_card.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EnrollFormPage extends StatefulWidget {
  const EnrollFormPage({super.key});

  @override
  State<EnrollFormPage> createState() => _EnrollFormPageState();
}

class _EnrollFormPageState extends State<EnrollFormPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? gender;
  String? selectedProvince;
  String? selectedCity;
  String? selectedBarangay;
  String? zipCode;
  String? gradeLevel;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController previousSchoolController =
      TextEditingController();
  final TextEditingController additionalInfoController =
      TextEditingController();

  final List<String> imagePaths = [];

  // Function to add an image to the list for demonstration purposes
  void _addImage(String imagePath) {
    setState(() {
      if (imagePaths.length < 4) {
        // Only allow up to 4 images
        imagePaths.add(imagePath);
      }
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dateOfBirthController.dispose();
    ageController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        title: Text(
          'STUDENT ENROLLMENT',
          style: CustomTextStyles.inknutAntiquaBlack(
              fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.bars, size: 34),
        ),
        centerTitle: true,
      ),
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const CustomCard(
                  color: CustomColors.appBarColor,
                  child: Text('ENROLLMENT FORM',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
                const SizedBox(height: 10),
                _buildForm(),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildAction(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return CustomCard(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PERSONAL INFORMATION:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTextField(fullNameController, "Student's Full Name"),
              const SizedBox(height: 10),
              _buildDateAndAgeFields(),
              const SizedBox(height: 10),
              _buildGenderSelection(),
              const SizedBox(height: 10),
              _buildAddressDropdowns(),
              if (zipCode != null) ...[
                Text('Zip Code: $zipCode'),
                const SizedBox(height: 10),
              ],
              _buildTextField(
                phoneNumberController,
                "Phone Number",
                isContactNumber: true,
                validator: (value) => TextValidator.validateContact(value),
              ),
              _buildTextField(
                emailController,
                "Email",
                validator: (value) => TextValidator.validateEmail(value),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('ACADEMIC INFORMATION:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTextField(previousSchoolController, "Previous School"),
              _buildGradeLevelSelection(),
              const Text(
                'Attach File: (PSA Birth Certificate, Card, Digital Signature):',
              ),
              const SizedBox(
                height: 10,
              ),
              _buildAction(true),
              const SizedBox(
                height: 10,
              ),
              _buildImageProofs(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Additional Info:',
              ),
              const SizedBox(
                height: 5,
              ),
              _buildTextField(additionalInfoController, "Add comments"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageProofs() {
    if (imagePaths.isEmpty) {
      return const SizedBox(); // Return an empty widget if there are no images
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Display two images per row
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePaths[index],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagePaths.removeAt(index); // Remove the specific image
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool? isContactNumber, String? Function(String?)? validator}) {
    return CustomTextFormField(
      toShow: false,
      controller: controller,
      hintText: hintText,
      toShowIcon: false,
      toShowPrefixIcon: false,
      isPhoneNumber: isContactNumber,
      validator: validator,
      maxLength: 50,
    );
  }

  Widget _buildDateAndAgeFields() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomTextFormField(
            toShow: false,
            controller: dateOfBirthController,
            ageController: ageController,
            hintText: 'Date of Birth',
            isDateTime: true,
            iconDataSuffix: Icons.calendar_month,
            toShowIcon: true,
            toShowPrefixIcon: false,
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
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        const Text('Gender: '),
        ...['Male', 'Female']
            .map((value) => buildGenderRadio(value, isGradeLevel: false)),
      ],
    );
  }

  Widget _buildGradeLevelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text('Grade Level Applying For: '),
        ...['Kindergarten', 'Elementary', 'Middle School']
            .map((value) => buildGenderRadio(value, isGradeLevel: true)),
      ],
    );
  }

  Widget buildGenderRadio(String value, {bool? isGradeLevel}) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: isGradeLevel! ? gradeLevel : gender,
          onChanged: (newValue) {
            setState(() {
              if (isGradeLevel) {
                gradeLevel = newValue; // Update grade level state
              } else {
                gender = newValue; // Update gender state
              }
            });
          },
          activeColor: Colors.black,
        ),
        Text(value),
      ],
    );
  }

  Widget _buildAddressDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Province:'),
        _buildDropdown<String>(
          value: selectedProvince,
          items: provinces.map((province) => province.name).toList(),
          hint: 'Choose a province',
          onChanged: (newValue) {
            setState(() {
              selectedProvince = newValue;
              selectedCity = null;
              selectedBarangay = null;
              zipCode = null;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text('Select City:'),
        _buildDropdown<String>(
          value: selectedCity,
          items: selectedProvince != null
              ? provinces
                  .firstWhere((p) => p.name == selectedProvince)
                  .cities
                  .map((city) => city.name)
                  .toList()
              : [],
          hint: 'Choose a city',
          onChanged: (newValue) {
            setState(() {
              selectedCity = newValue;
              selectedBarangay = null;
              zipCode = null;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text('Select Barangay:'),
        _buildDropdown<String>(
          value: selectedBarangay,
          items: selectedCity != null
              ? provinces
                  .firstWhere((p) => p.name == selectedProvince)
                  .cities
                  .firstWhere((c) => c.name == selectedCity)
                  .barangays
                  .map((barangay) => barangay.name)
                  .toList()
              : [],
          hint: 'Choose a barangay',
          onChanged: (newValue) {
            setState(() {
              selectedBarangay = newValue;
              zipCode = provinces
                  .firstWhere((p) => p.name == selectedProvince)
                  .cities
                  .firstWhere((c) => c.name == selectedCity)
                  .zipCode;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAction(bool forImage) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: CustomBtn(
              vertical: 0,
              colorBg: CustomColors.appBarColor,
              colorTxt: Colors.white,
              btnIcon: forImage ? Icons.add : Icons.cancel,
              btnTxt: forImage ? 'Add' : 'Clear',
              btnFontWeight: FontWeight.normal,
              txtSize: 14,
              onTap: () {
                if (forImage) {
                  _addImage(
                    CustomLogos.adventistLogo,
                  );
                } else {
                  setState(() {
                    // Clear image paths or any other lists
                    imagePaths.clear();

                    // Clear all text fields
                    fullNameController.clear();
                    dateOfBirthController.clear();
                    ageController.clear();
                    phoneNumberController.clear();
                    emailController.clear();
                    previousSchoolController.clear();
                    additionalInfoController.clear();

                    // Reset selection variables to null
                    gender = null;
                    selectedProvince = null;
                    selectedCity = null;
                    selectedBarangay = null;
                    zipCode = null;
                    gradeLevel = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: CustomBtn(
            vertical: 0,
            colorBg: CustomColors.appBarColor,
            colorTxt: Colors.white,
            btnIcon: forImage ? Icons.cancel : Icons.send,
            btnTxt: forImage ? 'Remove' : 'Submit',
            btnFontWeight: FontWeight.normal,
            txtSize: 14,
            onTap: () {
              if (forImage) {
                setState(() {
                  imagePaths.clear();
                });
              } else {}
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<String> items,
    required String hint,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item as T, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      hint: Text(hint),
      isExpanded: true,
    );
  }
}
