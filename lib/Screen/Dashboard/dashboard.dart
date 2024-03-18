import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salespro_saas_admin/Provider/seller_info_provider.dart';
import 'package:salespro_saas_admin/Screen/Dashboard/statistics_user_overview.dart';
import 'package:salespro_saas_admin/model/seller_info_model.dart';

import '../../Provider/get_subscription_request_privider.dart';
import '../../model/subscription_request_model.dart';
import '../../responsive.dart' as res;
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/Table Widgets/Dashboard/dashboard_table.dart';
import '../Widgets/Table Widgets/Total Count/total_count_widget.dart';
import '../Widgets/Topbar/topbar.dart';

class MtDashboard extends StatefulWidget {
  const MtDashboard({Key? key}) : super(key: key);

  static const String route = '/dashBoard';

  @override
  State<MtDashboard> createState() => _MtDashboardState();
}

class _MtDashboardState extends State<MtDashboard> {
  int numberOfFree = 0;
  int numberOfMonthly = 0;
  int numberOfHalfYearly = 0;
  int numberOfYear = 0;
  int numberOfLifetime = 0;
  int newReg = 0;

  void getData() async {
    //var data = await FirebaseDatabase.instance.ref('Admin panel');
  }

  @override
  void initState() {
    getData();
    super.initState();

    for (int i = 0; i < DateTime(currentDate.year, currentDate.month + 1, 0).day; i++) {
      everyDayOfCurrentMonth.add(0);
    }
    for (int i = 0; i < DateTime(currentDate.year, currentDate.month + 1, 0).day; i++) {
      everyDay.add(0);
    }
  }

  int i = 0;
  int newUserOfCurrentYear = 0;
  List<double> newUserMonthlyOfCurrentYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  List<SellerInfoModel> free = [];
  List<SellerInfoModel> monthly = [];
  List<SellerInfoModel> halfYearly = [];
  List<SellerInfoModel> yearly = [];
  List<SellerInfoModel> freeMonth = [];
  List<SellerInfoModel> newUser = [];
  List<SellerInfoModel> newUser30Days = [];
  List<SellerInfoModel> todayRegistration = [];
  List<SellerInfoModel> previousMonthRegistration = [];

  ///____________Incomes___________________________
  List<SubscriptionRequestModel> subOfCurrentYear = [];
  List<SubscriptionRequestModel> subOfCurrentMonth = [];
  List<SubscriptionRequestModel> subOfLastMonth = [];
  List<SubscriptionRequestModel> subOfLastYear = [];
  double totalIncomeOfCurrentYear = 0;
  double totalIncomeOfPreviousYear = 0;
  double totalIncomeOfCurrentMonth = 0;
  List<double> everyMonthOfYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<int> everyDayOfCurrentMonth = [];
  List<int> everyDay = [];
  double totalIncomeOfLastMonth = 0;
  List<SellerInfoModel> shopList = [];

  @override
  Widget build(BuildContext context) {
    i++;
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: res.Responsive(
        mobile: Container(),
        tablet: const MtDashboard(),
        desktop: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 1,
              child: SideBarWidget(
                index: 0,
                isTab: false,
              ),
            ),
            Expanded(
              flex: 5,
              child: Consumer(
                builder: (_, ref, watch) {
                  final sellerInfoData = ref.watch(sellerInfoProvider);
                  AsyncValue<List<SellerInfoModel>> infoList = ref.watch(sellerInfoProvider);
                  AsyncValue<List<SubscriptionRequestModel>> subscriptionData = ref.watch(subscriptionRequestProvider);
                  return infoList.when(data: (infoList) {
                    DateTime t = DateTime.now();
                    newUser = [];
                    free = [];
                    monthly = [];
                    halfYearly = [];
                    yearly = [];
                    freeMonth = [];
                    newUser = [];
                    newUser30Days = [];
                    todayRegistration = [];
                    previousMonthRegistration = [];

                    for (var element in infoList) {
                      if (element.subscriptionName == 'Free') {
                        free.add(element);
                      } else if (element.subscriptionName == 'Monthly') {
                        monthly.add(element);
                      } else if (element.subscriptionName == 'Kwa Miezi 6') {
                        halfYearly.add(element);
                      } else if (element.subscriptionName == 'Yearly') {
                        yearly.add(element);
                      }
                      final subscriptionDate = DateTime.parse(element.userRegistrationDate ?? (element.subscriptionDate.toString()));
                      if (subscriptionDate.isAfter(sevenDays)) {
                        newUser.add(element);
                      }
                      if (subscriptionDate.isAfter(firstDayOfCurrentYear)) {
                        newUserOfCurrentYear++;
                        newUserMonthlyOfCurrentYear[subscriptionDate.month - 1]++;
                        if (subscriptionDate.isAfter(firstDayOfCurrentMonth)) {
                          newUser30Days.add(element);
                          if (subscriptionDate.difference(t).inHours.abs() <= 24) {
                            newReg++;
                            todayRegistration.add(element);
                          }
                        }
                        if (subscriptionDate.isAfter(firstDayOfPreviousMonth) && subscriptionDate.isBefore(firstDayOfCurrentMonth)) {
                          previousMonthRegistration.add(element);
                        }
                      }
                    }

                    return subscriptionData.when(data: (paymentData) {
                      subOfCurrentYear = [];
                      subOfCurrentMonth = [];
                      subOfLastMonth = [];
                      subOfLastYear = [];
                      totalIncomeOfCurrentYear = 0;
                      totalIncomeOfPreviousYear = 0;
                      totalIncomeOfCurrentMonth = 0;
                      everyMonthOfYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                      totalIncomeOfLastMonth = 0;
                      shopList = [];
                      for (var element in paymentData) {
                        if (element.status == 'approved') {
                          final subscriptionDate = DateTime.tryParse(element.approvedDate.toString()) ?? DateTime.now();

                          if (subscriptionDate.isAfter(firstDayOfCurrentYear)) {
                            totalIncomeOfCurrentYear += element.amount;

                            everyMonthOfYear[subscriptionDate.month - 1] += element.amount;
                            everyDay[subscriptionDate.day - 1] += element.amount;

                            subOfCurrentYear.add(element);

                            if (subscriptionDate.isAfter(firstDayOfCurrentMonth)) {
                              totalIncomeOfCurrentMonth += element.amount;
                              subOfCurrentMonth.add(element);
                              everyDayOfCurrentMonth[subscriptionDate.day - 1]++;
                            }

                            if (subscriptionDate.isAfter(firstDayOfPreviousMonth) && subscriptionDate.isBefore(firstDayOfCurrentMonth)) {
                              totalIncomeOfLastMonth += element.amount;
                              subOfLastMonth.add(element);
                            }
                            if (subscriptionDate.isAfter(firstDayOfPreviousYear) && subscriptionDate.isBefore(firstDayOfCurrentYear)) {
                              totalIncomeOfPreviousYear += element.amount;
                              subOfLastYear.add(element);
                            }
                          }
                        }
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            //TopBar
                            Container(
                              padding: const EdgeInsets.all(6.0),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: kWhiteTextColor,
                              ),
                              child: const TopBar(),
                            ),

                            //Counter
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TotalCount(
                                    icon: 'images/user.svg',
                                    title: 'Total User',
                                    count: infoList.length.toString(),
                                    backgroundColor: const Color(0xFFDAD4FF),
                                    iconBgColor: const Color(0xFF8424FF),
                                  ),
                                  const SizedBox(width: 10.0),
                                  TotalCount(
                                    icon: 'images/new.svg',
                                    title: 'New User',
                                    count: newUser.length.toString(),
                                    backgroundColor: const Color(0xFFFFE4C1),
                                    iconBgColor: const Color(0xFFFFA609),
                                  ),
                                  const SizedBox(width: 10.0),
                                  TotalCount(
                                    icon: 'images/free.svg',
                                    title: 'Free Plan User',
                                    count: free.length.toString(),
                                    backgroundColor: const Color(0xFFCFFFCA),
                                    iconBgColor: const Color(0xFF0ED128),
                                  ),
                                  const SizedBox(width: 10.0),
                                  TotalCount(
                                    icon: 'images/month.svg',
                                    title: 'Monthly Plan User',
                                    count: monthly.length.toString(),
                                    backgroundColor: const Color(0xFFFFE2EB),
                                    iconBgColor: const Color(0xFFFF2267),
                                  ),
                                  // const SizedBox(width: 10.0),
                                  // TotalCount(
                                  //   icon: FontAwesomeIcons.crown,
                                  //   title: '6 Month User Plan ',
                                  //   count: halfYearly.length.toString(),
                                  //   backgroundColor: const Color(0xFFFFE1E1),
                                  //   iconBgColor: const Color(0xFFFF436C),
                                  // ),
                                  const SizedBox(width: 10.0),
                                  TotalCount(
                                    icon: 'images/year.svg',
                                    title: 'Yearly Plan User',
                                    count: yearly.length.toString(),
                                    backgroundColor: Colors.blue.withOpacity(0.1),
                                    iconBgColor: Colors.blue,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: StatisticsData(
                                      totalIncomeCurrentMonths: totalIncomeOfCurrentMonth,
                                      totalIncomeLastMonth: totalIncomeOfLastMonth,
                                      totalIncomeCurrentYear: totalIncomeOfCurrentYear,
                                      allMonthData: everyMonthOfYear,
                                      allDay: everyDay,
                                      totalUser: double.parse(
                                        infoList.length.toString(),
                                      ),
                                      freeUser: double.parse(
                                        free.length.toString(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 380,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        color: kWhiteTextColor,
                                      ),
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: TopSellingStore(
                                                newReg1: newUser,
                                                monthlyReg: newUser30Days,
                                                previousReg: previousMonthRegistration,
                                                totalUSer: infoList.length.toString() ?? '',
                                              )),

                                              ///_________________________________________________
                                              Expanded(
                                                  child: Subscribed(
                                                subOfCurrentMonth: subOfCurrentMonth,
                                                subOfCurrentYear: subOfCurrentYear,
                                                subOfLastMonth: subOfLastMonth,
                                                totalNewUserCurrentYear: newUserOfCurrentYear,
                                                userInMonthOfYear: newUserMonthlyOfCurrentYear,
                                              )),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              ///________________________________________________
                                              Expanded(
                                                child: IncomeSection(
                                                  totalIncomeCurrentMonths: totalIncomeOfCurrentMonth,
                                                  totalIncomeLastMonth: totalIncomeOfLastMonth,
                                                  totalIncomeCurrentYear: totalIncomeOfCurrentYear,
                                                  allMonthData: everyMonthOfYear,
                                                ),
                                              ),

                                              Expanded(
                                                child: ExpenseSection(
                                                  totalIncomeCurrentMonths: totalIncomeOfCurrentMonth,
                                                  totalIncomeLastMonth: totalIncomeOfLastMonth,
                                                  totalIncomeCurrentYear: totalIncomeOfCurrentYear,
                                                  allMonthData: everyMonthOfYear,
                                                  totalIncomeLastYear: totalIncomeOfPreviousYear,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      height: 360,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6.0),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Recently Registered Users',
                                            style: TextStyle(color: kTitleColor, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10.0),
                                          sellerInfoData.when(data: (sellerSnap) {
                                            shopList = sellerSnap;
                                            List<SellerInfoModel> lastShopList = shopList.length > 5 ? shopList.sublist(shopList.length - 5) : shopList;
                                            lastShopList = lastShopList.reversed.toList();
                                            return SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: DataTable(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6.0),
                                                ),
                                                border: TableBorder.all(borderRadius: BorderRadius.circular(6.0), color: kBorderColorTextField),
                                                showCheckboxColumn: true,
                                                dividerThickness: 1.0,
                                                dataRowColor: const MaterialStatePropertyAll(Colors.white),
                                                headingRowColor: MaterialStateProperty.all(const Color(0xffF8F1FF)),
                                                showBottomBorder: false,
                                                headingTextStyle: const TextStyle(
                                                  color: kTitleColor,
                                                ),
                                                dataTextStyle: const TextStyle(color: Color(0xff525252)),
                                                columns: const [
                                                  DataColumn(label: Text('S.L')),
                                                  DataColumn(label: Text('Name')),
                                                  DataColumn(label: Text('Email')),
                                                  DataColumn(label: Text('Subscription Plan',overflow: TextOverflow.ellipsis,)),
                                                ],
                                                rows: List.generate(
                                                  lastShopList.reversed.toList().length,
                                                  (index) => DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(
                                                          (index + 1).toString(),
                                                          textAlign: TextAlign.start,
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(lastShopList[index].companyName.toString()),
                                                      ),
                                                      DataCell(
                                                        Text(lastShopList[index].email.toString()),
                                                      ),
                                                      DataCell(
                                                        Text(lastShopList[index].subscriptionName.toString()),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }, error: (e, stack) {
                                            return Center(
                                              child: Text(e.toString()),
                                            );
                                          }, loading: () {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          })
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Expanded(
                                    flex: 2,
                                    child: UserOverView(
                                      totalUser: double.parse(
                                        infoList.length.toString(),
                                      ),
                                      freeUser: double.parse(
                                        free.length.toString(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }, error: (e, stock) {
                      return Center(
                        child: Text(e.toString()),
                      );
                    }, loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    });
                  }, error: (e, stack) {
                    return Center(
                      child: Text(e.toString()),
                    );
                  }, loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
