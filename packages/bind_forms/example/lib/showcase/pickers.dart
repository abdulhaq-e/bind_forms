import 'package:bind_forms/bind_forms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';
import 'package:material_ui/material_ui.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'demo.dart';

/// Picker wrappers wrap an async function behind a tap target. Without
/// them, it's a button that awaits the function and writes the result.
class PickersPage extends StatelessWidget {
  const PickersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(title: 'Pickers', children: pickerDemos());
  }
}

String _count(int? count, String noun) => switch (count) {
  null || 0 => 'Pick ${noun}s',
  1 => '1 $noun',
  _ => '$count ${noun}s',
};

/// The demos on [PickersPage], also pumped one by one by the smoke test.
List<Widget> pickerDemos() => [
  ValueDemo<List<PlatformFile>>(
    title: 'FilePicker.pickFiles',
    replaces: 'reactive_file_picker',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<List<PlatformFile>>(
      field: field,
      icon: Icons.attach_file,
      label: _count(field.value?.length, 'file'),
      pick: () => FilePicker.pickFiles(),
    ),
  ),
  ValueDemo<List<XFile>>(
    title: 'openFiles (file_selector)',
    replaces: 'reactive_file_selector',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<List<XFile>>(
      field: field,
      icon: Icons.folder_open,
      label: _count(field.value?.length, 'file'),
      pick: () => openFiles(),
    ),
  ),
  ValueDemo<XFile>(
    title: 'ImagePicker.pickImage',
    replaces: 'reactive_image_picker',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<XFile>(
      field: field,
      icon: Icons.image_outlined,
      label: field.value?.name ?? 'Pick an image',
      pick: () => ImagePicker().pickImage(source: ImageSource.gallery),
    ),
  ),
  ValueDemo<List<AssetEntity>>(
    title: 'AssetPicker.pickAssets',
    replaces: 'reactive_wechat_assets_picker',
    note: 'Android, iOS and macOS only.',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<List<AssetEntity>>(
      field: field,
      icon: Icons.photo_library_outlined,
      label: _count(field.value?.length, 'asset'),
      pick: () => AssetPicker.pickAssets(context),
    ),
  ),
  ValueDemo<AssetEntity>(
    title: 'CameraPicker.pickFromCamera',
    replaces: 'reactive_wechat_camera_picker',
    note: 'Android and iOS only.',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<AssetEntity>(
      field: field,
      icon: Icons.photo_camera_outlined,
      label: field.value?.title ?? 'Take a photo',
      pick: () => CameraPicker.pickFromCamera(context),
    ),
  ),
  ValueDemo<PhoneContact>(
    title: 'FlutterContactPicker.pickPhoneContact',
    replaces: 'reactive_contact_picker',
    note: 'Android and iOS only.',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<PhoneContact>(
      field: field,
      icon: Icons.contact_phone_outlined,
      label: field.value?.fullName ?? 'Pick a contact',
      pick: FlutterContactPicker.pickPhoneContact,
    ),
  ),
  ValueDemo<DateTime>(
    title: 'showMonthPicker',
    replaces: 'reactive_month_picker_dialog',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<DateTime>(
      field: field,
      icon: Icons.calendar_month,
      label: field.value == null
          ? 'Pick a month'
          : '${field.value!.year}-'
                '${field.value!.month.toString().padLeft(2, '0')}',
      pick: () => showMonthPicker(context: context, initialDate: field.value),
    ),
  ),
  ValueDemo<Language>(
    title: 'LanguagePickerDialog',
    replaces: 'reactive_language_picker',
    control: () => FormControl(value: Languages.arabic),
    builder: (context, field) => PickerButton<Language>(
      field: field,
      icon: Icons.translate,
      label: field.value?.name ?? 'Pick a language',
      pick: () => showDialog<Language>(
        context: context,
        builder: (context) => LanguagePickerDialog(
          title: const Text('Language'),
          onValuePicked: (language) => Navigator.pop(context, language),
        ),
      ),
    ),
  ),
];
