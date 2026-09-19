import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConstitutionScreen extends StatelessWidget {
  const ConstitutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Our Constitution", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📜 Jalal Welfare Organization',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Constitution & By-Laws',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Article I: Name & Address
            _buildSection(
              title: '📋 Article I: Name & Address',
              content: '''
1. Name of the agency (seeking registration): JALAL WELFARE ORGANIZATION.
2. Address: Village Badalai P/O & Tehsil Wari District Dir Upper.
3. Date of establishment: 16/12/2019
4. Operational Region: Dir Upper_Badalai 
5. Contact: 0348-9414488
6. Total Membership: N/A
7. Total Fund: Rs. 2,545,500/-
8. Total Expenditure: Rs. 2,245,500/-
              ''',
            ),

            // Article II: Membership Categories
            _buildSection(
              title: '👥 Article II: Membership Categories',
              content: '''
1. Patron: A Person who pays Rs.1000/- or more in lumps sum to the Organization and whose links with the Organization is helpful for the promotion of the objectives of the Organization shall be invited by the executive body to be its patron.

2. Ordinary Members: Any person who applied on the prescribed form may become a member Subject to introduction and recommendation to the executive body on payment of registration membership fee Rs.150/- and monthly fee Rs.100/-.

3. Honorary Members: Any person who renders meritorious services for the causes of the Organization may be nominated an honorary member by the executive body without payment of membership fee.
              ''',
            ),

            // Article III: Procedure for Admission
            _buildSection(
              title: '📝 Article III: Procedure for Admission of Members',
              content: '''
1. Patron: A person who fulfills the condition laid down under article - 5 clause (2) may be invited by the executive body to become patron of the Organization.

2. Ordinary Members: A Person who fulfills the requirements as laid down by article - 5 clause (2) and desirous to become ordinary member shall apply on prescribed form of the Organization. The executive body shall have power to accept or reject such application. A person shall become the ordinary member of the Organization only after payment of the prescribed fee.

3. Honorary Member: The executive body of the organization shall nominate honorary members. The honorary members will be the persons who have eminent service for the organization and the community. He/she will not be required to pay any membership fee.

Procedure for Rejection:
Person whose application for membership is rejected by the executive body can apply again after lapse of three months (3). The application rejected second time by the executive body shall be put up before the general body for consideration providing reasons for rejection. A person whose application is rejected by the executive body will have the right to appeal to the general body whose decision shall be final.
              ''',
            ),

            // Article IV: Rights & Privileges
            _buildSection(
              title: '⚖️ Article IV: Rights and Privileges of Members',
              content: '''
The following categories of members shall have the right to vote:
• Ordinary Members

The following categories of members shall not have the right to vote and hold office but can participate in the meetings and functions of the organization:
• Honorary Members
• Members who have not cleared dues till their due date.
              ''',
            ),

            // Article V: Suspension & Cancellation
            _buildSection(
              title: '🚫 Article V: Procedure of Suspension, Cancellation & Registration of Membership',
              content: '''
Membership may be terminated in any of the following cases:

1) Non-payment of Subscriptions:
For non- payment of fees up to 30 days after the due date. General Secretary will issue 15 days' notice to defaulter members prior to the due date a second notice of 15 days will be given at the expiry of the notice period if the dues are not cleared as per second notice, the person concerned membership will be ceased.

2) Absence for meeting (General body & executive body):
A member who fails to attend three consecutive meeting without prior intimation or justification shall cease to be a member of executive body or General body as per following procedure.

The executive body shall give 15 days notice to defaulting members within which he shall submit a written reply of his conduct. In the event of explanation, being found unsatisfactory by the executive body may either administer a warning or may ask the member to resign the membership for the Organization forthwith.

3) Conduct being Detrimental to the interests of the agency:
If Conduct of any member is deemed by the executive body to be prejudicial to the interest of the organization, or calculated to bring the organization into disrepute, his membership can suspended/cancelled according to the following procedures.

He/she shall be given a notice of at least 15 days by the executive body during which he shall submit a written explanation of his conduct. In the event of explanation being founded unsatisfactory the executive body may either give a warning or may ask the membership to resign his membership for the organization forthwith.

Procedure for Restoration:
1) Non-payment: In Case the membership is cancelled due to non- payment, it may be restored after payment of all outstanding dues subject the approval of the executive body.
2) Detrimental Conduct: In Case of his/her conduct being detrimental to the interests of the organization, the executive body, if it satisfied may restore his/her membership after written assurance is given by him that he/she will not work against the interest of organization in future.
3) Appeal: In Case the person's membership is not restored by the executive body, He/she have the right to appeal to the general body.
              ''',
            ),

            // Article VI: Branches
            _buildSection(
              title: '🏢 Article VI: Branches',
              content: '''
In branches exist of Instict Dir Upper at this time, however in future if organization establishes its branches, prior approval of the Registration Authority is mandatory.
              ''',
            ),

            // Article VII: Organizational Structure
            _buildSection(
              title: '🏛️ Article VII: Organizational Structure',
              content: '''
Composition of the Executive Body/ Governing Body:
• President/Chairman - One
• Vice President/Chairman - One
• General Secretary - One
• Joint Secretary - One
• Finance Secretary - One
• Information Secretary - One
• Coordination Secretary - One

Powers & Functions of the Executive Body:
• To act and represent the Organization in all matters and execute the policy and decision of the General body.
• To invite, nominate, accept, suspend, cancel, or restore the membership of the persons according to the provisions of the Article.
• To appoint, suspend, punish, or dismiss paid staff of the organization if deemed necessary.
• To prepare schemes, budget and progress report and will be responsible for maintenance and case study of office records and property of.
• To maintain a register of member and keep it up to date in which the name and addresses of all categories of members of the organization.
• All property movable as well as immovable, belonging to the organization shall use in the executive body, which shall administer it only for the aims and objectives of the organization.
              ''',
            ),

            // Article VIII: Office Bearers
            _buildSection(
              title: '👔 Article VIII: Office Bearers',
              content: '''
1. Chairman/President:
The chairman/president shall be the constitutional head of the organization and shall preside all meetings. He/she shall ensure that the provision of the constitution is duly carried in all respect. Shall have the power to sanction expenditure up to Rs.5000/- in each case subject to approval by the executive body in subsequent meetings. He/she shall have the right of casting vote in any meeting in case of tie. He/she shall operate bank account jointly with finance Secretary of the organization.

2. Vice Chairman/President:
Shall exercise all power of the Chairman/President in his absence & in his presence will assist the Chairman/President.

3. General Secretary:
The General Secretary shall be the chief executive of the organization and shall act in consulting with the Chairman/President and shall be responsible for the executive body. The General Secretary in the consultation with the Chairman/President shall prepare the agenda, call meeting of the general body and executive body in accordance with the provision of the constitution, prepare and put up the minutes of the last meeting for confirmation and maintain proper record of the same. The General Secretary shall be responsible for the execution of the resolution and directive of the executive body & General body.

4. Joint Secretary:
In the absence of the General, joint Secretary shall exercise all the powers and function of the General Secretary and in his presence, shall assist the General Secretary.

5. Finance Secretary:
The finance secretary shall maintain accounts of the income and expenditure and be in charge of the finance of the organization. The finance secretary shall within three days of the receipt, deposit the entire amount in the bank duly approved by the organization authority in the account of the organization. He/she shall operate bank accounts jointly with the Chairman/President. He/she shall arrange collection of donations, grants, aids, subscription & other payments on the behalf of the organization and issue proper receipt.

6. Information Secretary:
He/she give publicity to all the aims and objectives of the organization and publication of all such materials aimed at gaining help and support from line agencies, print and electronic media.

7. Coordination Secretary:
Responsible for coordination between different departments and ensuring smooth functioning of all activities.
              ''',
            ),

            // Article IX: Future Plans
            _buildSection(
              title: '🚀 Future Plans',
              content: '''
1. Establishment of skill Development Center like Vocational and Computer.
2. Establishment of Model School and Colleges in the rural and remote areas of the province.
3. Literacy Centers (Education for All).
4. Education Support for orphan and poor.
5. Welfare of Patient particularly poor.
6. Micro credit and home industries for women & self-help groups.
7. Promoting employment for young men and women.
8. Improving community physical infrastructure.
9. Capacity Building and Trainings Programs.
10. Advocacy for Women, Children and Disabled People for their rights.
11. Rehabilitation and shelter for the marginalized segments of the community i.e. children, women, elderly etc.
12. Awareness about different social and other issues.
              ''',
            ),

            // Article X: Role of District Officer
            _buildSection(
              title: '👤 Article X: Role of District Officer Social Welfare',
              content: '''
He/she will be the technical advisor in formation of policies of the Agency. He/she shall monitor the election of the agency. He/she may attend every meeting of General body and/or any if its function and with his/her assistance grant - in - aid application will be prepared and submitted through his/her office to the Provincial Council of Social Welfare.

He/she can check account and other records of agency at any time and all relevant record will be provided whenever demanded. He/she can pay visits to the organization and inspect any document without prior intimation or notice.
              ''',
            ),

            // Article XI: Dissolution
            _buildSection(
              title: '⚖️ Article XI: Voluntarily Dissolution of the Organization',
              content: '''
The organization shall be dissolved in accordance with section 11 & 12 of the voluntary Social Welfare Agencies (Registration & Control) Ordinance 1961. Dissolution shall only be decided at special meeting of the General Body, socially called for the fortnight notice. The decision taken would be communicated to the Registration Authority for further necessary action.

In the event of dissolution of the organization, its assets, left after meeting its liability if any, shall be transferred to any other voluntary agencies having similar objectives, registered under the voluntary social welfare agency (R & C) ordinance 1961.
              ''',
            ),

            // Article XII: Financial Summary
            _buildSection(
              title: '💰 Financial Summary',
              content: '''
Total Income: Rs. 2,545,500/-
Total Expenditure: Rs. 2,245,500/-
Balance: Rs. 300,000/-

Major Expenditures:
• Welfare of widows, orphans, poor peoples: Rs. 900,000
• Catering/Goods: Rs. 550,000
• Ramzan Package: Rs. 100,000
• Eide Package: Rs. 40,000
• Cloth for orphans: Rs. 80,000
• Health care of poor people: Rs. 30,000
• Construction of Social Work: Rs. 50,000
• Stationary for organization: Rs. 20,000
• Launching ceremony program & board: Rs. 5,000
• Middles for position holder Social Workers: Rs. 5,500
• Flexes for Tanzim: Rs. 15,000
              ''',
            ),

            const SizedBox(height: 20),

            // Authorized Signature - Qamar Zada
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green.shade700),
                      const SizedBox(width: 10),
                      Text(
                        '✍️ Authorized Signature',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This constitution is hereby approved and adopted by the Executive Body of Jalal Welfare Organization. All provisions contained herein shall be binding on all members and office bearers.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Qamar Zada',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'President',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Jalal Welfare Organization',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '𝓠𝓪𝓶𝓪𝓻 𝓩𝓪𝓭𝓪',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Brush Script MT',
                              ),
                            ),
                            const Text(
                              'Authorized Signatory',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                              ),
                            ),
                            const Text(
                              'Jalal Welfare Organization',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Verified ✅',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Contact Bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _contactItem(Icons.phone, '+92 341 5566663'),
                        _contactItem(Icons.facebook, 'جلال فلاحی تنظیم'),
                        _contactItem(Icons.public, 'www.jalalwelfare.org'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // More Details Link
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Text(
                        '📖 For Complete Constitution Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://drive.google.com/file/d/1hLvvZgXPySdbCyryE2tFo7XG0Ab_eZDK/view?usp=drivesdk',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open link')),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'View Full Constitution (PDF)',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.green.shade100),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}