import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final cricket = ['Sachin_Tendulkar', 'Virat_Kohli', 'MS_Dhoni', 'Rohit_Sharma', 'Jasprit_Bumrah', 'Ravindra_Jadeja', 'KL_Rahul', 'Hardik_Pandya', 'Yuvraj_Singh', 'Sourav_Ganguly', 'Kapil_Dev', 'Rahul_Dravid', 'VVS_Laxman', 'Anil_Kumble', 'Zaheer_Khan', 'Shikhar_Dhawan', 'Ravichandran_Ashwin', 'Sunil_Gavaskar', 'Virender_Sehwag', 'Rishabh_Pant'];
  final bolly = ['Shah_Rukh_Khan', 'Salman_Khan', 'Aamir_Khan', 'Amitabh_Bachchan', 'Hrithik_Roshan', 'Akshay_Kumar', 'Ranbir_Kapoor', 'Ranveer_Singh', 'Deepika_Padukone', 'Priyanka_Chopra', 'Katrina_Kaif', 'Alia_Bhatt', 'Kareena_Kapoor', 'Anushka_Sharma', 'Ajay_Devgn', 'Shahid_Kapoor', 'Ayushmann_Khurrana', 'Kartik_Aaryan', 'Shraddha_Kapoor', 'Kiara_Advani'];

  await fetchAndPrint('CRICKETERS', cricket);
  await fetchAndPrint('BOLLYWOOD', bolly);
}

Future<void> fetchAndPrint(String name, List<String> titles) async {
  print('--- $name ---');
  final url = Uri.parse('https://en.wikipedia.org/w/api.php?action=query&titles=' + titles.join('|') + '&prop=pageimages&format=json&pithumbsize=400');
  
  final request = await HttpClient().getUrl(url);
  request.headers.set('User-Agent', 'Mozilla/5.0');
  final response = await request.close();
  
  final stringData = await response.transform(utf8.decoder).join();
  final data = jsonDecode(stringData);
  final pages = data['query']['pages'] as Map<String, dynamic>;
  
  for (final page in pages.values) {
    if (page['thumbnail'] != null) {
      final t = page['title'];
      final i = page['thumbnail']['source'];
      print("    Character(name: '$t', imageUrl: '$i'),");
    } else {
      final t = page['title'];
      print("    // NO IMAGE: $t");
    }
  }
}
