import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/request_model/contact/contact_model.dart';
import '../../models/request_model/social/social_response_model.dart';

abstract class ContactRemoteDataSource {
  Future<ApiResultModel<String?>> contact(ContactModel model);
  Future<ApiResultModel<SocialResponseModel?>> getSocialLinks();
}
