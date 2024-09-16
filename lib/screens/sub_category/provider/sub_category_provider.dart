import 'dart:developer';

import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';


class SubCategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addSubCategoryFormKey = GlobalKey<FormState>();
  TextEditingController subCategoryNameCtrl = TextEditingController();
  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;




  SubCategoryProvider(this._dataProvider);


  //TODO: should complete addSubCategory 12. task completed by siddhant  ( 1 st for sub category);
  addSubCategory() async {
    try{
      Map<String,dynamic> subCategory={'name':subCategoryNameCtrl.text,'categoryId':selectedCategory?.sId};
      final response=await service.addItem(endpointUrl: 'subCategories', itemData: subCategory);
      if(response.isOk)
      {
        ApiResponse apiResponse=ApiResponse.fromJson(response.body, null);

        if(apiResponse.success==true)
        {
          
          clearFields();
          SnackBarHelper.showSuccessSnackBar("${apiResponse.message}");
          log("sub category added");
        }
        else
        {
          SnackBarHelper.showErrorSnackBar("failed to add sub category due to ${apiResponse.message}");
          
        }
      }else{
        SnackBarHelper.showErrorSnackBar("failed to add sub category due to ${response.body['message'] ?? response.statusText}");
      }
      

    }catch(e)
    {
      print(e);
      SnackBarHelper.showErrorSnackBar("failed to add sub category due to $e");
      rethrow;
    }
  }


  //TODO: should complete updateSubCategory

  //TODO: should complete submitSubCategory


  //TODO: should complete deleteSubCategory


  setDataForUpdateCategory(SubCategory? subCategory) {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';
      selectedCategory = _dataProvider.categories.firstWhereOrNull((element) => element.sId == subCategory.categoryId?.sId);
    } else {
      clearFields();
    }
  }

  clearFields() {
    subCategoryNameCtrl.clear();
    selectedCategory = null;
    subCategoryForUpdate = null;
  }

  updateUi(){
    notifyListeners();
  }
}
