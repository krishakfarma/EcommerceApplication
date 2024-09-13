import 'dart:developer';
import 'dart:io';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;


  File? selectedImage;
  XFile? imgXFile;


  CategoryProvider(this._dataProvider);

  //TODO: should complete addCategory 1. task by siddhant
  addCategory() async
  {
    try{
      if(selectedImage == null)
      {
        Get.snackbar("Error", "Please select image");
        return; // ? stop the program eviction
      }
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image':'no_data' //? image path will added from server side
      };
      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response= await service.addItem(endpointUrl: 'categories', itemData: form);

      if(response.isOk)
      {
        print("category addition api is connected sucessfully "+response.body.toString()+" "+response.statusCode.toString());
        ApiResponse apiResponse=ApiResponse.fromJson(response.body,null);
        if(apiResponse.success==true)
        {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          log("category added !!!");
        }
        else
        {
          SnackBarHelper.showErrorSnackBar("Failed to add category "+'${apiResponse.message}');
        }
        


      }else
        {
          SnackBarHelper.showErrorSnackBar("Something went wrong ${response.body?['message'] ?? response.statusText}");
        }



      

    }catch(e)
    {
      print(e);
      SnackBarHelper.showErrorSnackBar("An Error occured "+e.toString());
      rethrow;
    }

  }




  //TODO: should complete updateCategory 7.task completed by siddhant
  updateCategory() async
  {
    try{
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image':categoryForUpdate?.image ?? '',
      };

      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response= await service.updateItem(endpointUrl: 'categories', itemData: form,itemId: categoryForUpdate?.sId ?? '');

      if(response.isOk)
      {
        ApiResponse apiResponse=ApiResponse.fromJson(response.body,null);
        if(apiResponse.success==true)
        {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          log("category updated !!!");
        }
        else
        {
          SnackBarHelper.showErrorSnackBar("Failed to update category "+'${apiResponse.message}');
        }
      }
      else{
        SnackBarHelper.showErrorSnackBar("Something went wrong ${response.body?['message'] ?? response.statusText}");
      }




    }catch(e)
    {
      print(e);
      SnackBarHelper.showErrorSnackBar("An Error occured "+e.toString());
      rethrow;
    }
  }

  //TODO: should complete submitCategory 8. task completed by siddhant  there are two button one is add and another is submit that why we require the set this condition
  submitCategory() async
  {
    if(categoryForUpdate!=null)
    {
      updateCategory();
      
    }
    else
    {
      addCategory();
    }
  }


  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  //TODO: should complete deleteCategory 10. task completed by siddhant to delete the category 
  deleteCategory(Category category) async
  {
    try{
      Response response= await service.deleteItem(endpointUrl: 'categories', itemId: category.sId ?? '');
      if(response.isOk)
      {
        ApiResponse apiResponse=ApiResponse.fromJson(response.body,null);
        if(apiResponse.success==true)
        {
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          log("category deleted !!!");
        }

      }else{
        SnackBarHelper.showErrorSnackBar("Something went wrong ${response.body?['message'] ?? response.statusText}");
      }



    }catch(e)
    {
      print(e);
      SnackBarHelper.showErrorSnackBar("An Error occured "+e.toString());
      rethrow;
    }
  }






  //TODO: should complete setDataForUpdateCategory 9.task completed by siddhant in add_category_form.dart at start 


  //? to create form data for sending image with body
  Future<FormData> createFormData({required XFile? imgXFile, required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
