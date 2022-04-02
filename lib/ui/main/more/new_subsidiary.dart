import 'package:co/ui/main/more/new_subsidiary_main.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class NewSubsidiary extends StatefulWidget {
  const NewSubsidiary({Key? key}) : super(key: key);
  @override
  NewSubsidiaryState createState() => NewSubsidiaryState();
}

class NewSubsidiaryState extends State<NewSubsidiary> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('sign_up_info2');
  final LocalStorage tokenStorage = LocalStorage('token');
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('65');
  String industryFilteredQuery = Queries.QUERY_INDUSTRY_FILTERD;
  String listCompanyTypeQuery = Queries.QUERY_LIST_COMPANY_TYPE;
  String getCountryQuery = Queries.QUERY_GET_COUNTRY;
  String getUserQuery = Queries.QUERY_DASHBOARD_LAYOUT;
  String createOrganizationMutation = FXRMutations.MUTATION_CREATE_ORGANIZATION;

  final companyNameCtl = TextEditingController();
  final companyNumberCtl = TextEditingController();
  final countryCtl = TextEditingController();
  final companyTypeCtl = TextEditingController();
  final companyPhoneNumberCtl = TextEditingController();
  final companyAddressCtl = TextEditingController();
  final companyPostalCodeCtl = TextEditingController();
  final industryCtl = TextEditingController();
  final cityCtl = TextEditingController();
  final vnBuildingNameCtl = TextEditingController();
  final vnWardNumberCtl = TextEditingController();
  final vnDistrictCtl = TextEditingController();
  var selectedIndustryArr = [];
  var selectedCity = {};
  String selectedCompanyType = '';

  @override
  void initState() {
    super.initState();
    storage.setItem('country', _selectedDialogCountry.isoCode);
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Query(
        options: QueryOptions(
          document: gql(industryFilteredQuery),
          variables: {"industryTerm": ""},
        ),
        builder: (QueryResult industryResult,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (industryResult.hasException) {
            return Material(
                child: Scaffold(body: CustomNoInternet(handleTryAgain: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (context) => NewSubsidiary()))
                  .then((value) => setState(() => {}));
            })));
          }

          if (industryResult.isLoading) {
            return CustomLoading();
          }
          var industry = industryResult.data!['industriesFiltered'];
          return Query(
              options: QueryOptions(
                document: gql(listCompanyTypeQuery),
                variables: {"country": _selectedDialogCountry.isoCode},
              ),
              builder: (QueryResult listCompanyResult,
                  {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (listCompanyResult.hasException) {
                  return Material(child:
                      Scaffold(body: CustomNoInternet(handleTryAgain: () {
                    Navigator.of(context)
                        .push(new MaterialPageRoute(
                            builder: (context) => NewSubsidiary()))
                        .then((value) => setState(() => {}));
                  })));
                }
                if (listCompanyResult.isLoading) {
                  return CustomLoading();
                }
                var listCompany = listCompanyResult.data!['LIST_COMPANY_TYPES'];

                List<String> listCompanyArr = [];
                listCompany.forEach((item) {
                  listCompanyArr.add(item['name']);
                });
                return Query(
                    options: QueryOptions(
                      document: gql(getUserQuery),
                      variables: {},
                    ),
                    builder: (QueryResult userResult,
                        {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (userResult.hasException) {
                        return Material(child:
                            Scaffold(body: CustomNoInternet(handleTryAgain: () {
                          Navigator.of(context)
                              .push(new MaterialPageRoute(
                                  builder: (context) => NewSubsidiary()))
                              .then((value) => setState(() => {}));
                        })));
                      }
                      if (userResult.isLoading) {
                        return CustomLoading();
                      }
                      var userInfo = userResult.data!['user'];
                      return NewSubsidiaryMain(
                          industry: industry,
                          listCompany: listCompany,
                          userInfo: userInfo);
                    });
              });
        });
  }
}
