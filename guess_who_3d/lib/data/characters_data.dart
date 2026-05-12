import '../models/character.dart';

class CharactersData {
  // Use DiceBear Avataaars API for unique character avatars for default characters
  static String _avatarUrl(String seed) =>
      'https://api.dicebear.com/7.x/avataaars/png?seed=$seed&size=200&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf';

  static List<Character> getDefaultCharacters() {
    // Combine some Bollywood and Cricketer icons to make a default list of 20 real characters
    final list = <Character>[];
    list.addAll(getBollywoodIcons().take(10));
    list.addAll(getIndianCricketers().take(10));
    return list;
  }

  static List<Character> getBollywoodIcons() {
    return [
      Character(name: 'Aamir Khan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/65/Aamir_Khan_at_the_success_bash_of_Secret_Superstar.jpg'),
      Character(name: 'Ajay Devgn', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Ajay_Devgn_at_the_trailer_launch_of_Raid_2.jpg'),
      Character(name: 'Akshay Kumar', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Akshay_Kumar_National_Award_for_Padman_%28cropped%29.jpg/500px-Akshay_Kumar_National_Award_for_Padman_%28cropped%29.jpg'),
      Character(name: 'Alia Bhatt', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Alia_Bhatt_at_Berlinale_2022_Ausschnitt.jpg/500px-Alia_Bhatt_at_Berlinale_2022_Ausschnitt.jpg'),
      Character(name: 'Amitabh Bachchan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Indian_actor_Amitabh_Bachchan.jpg/500px-Indian_actor_Amitabh_Bachchan.jpg'),
      Character(name: 'Anushka Sharma', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e6/Anushka_Sharma_promoting_Zero.jpg'),
      Character(name: 'Ayushmann Khurrana', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e4/Ayushmann_Khurrana_promotos_%27Anek%27_in_Delhi_%281%29_%28cropped%29.jpg'),
      Character(name: 'Deepika Padukone', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Deepika_Padukone_2025_%281%29.png/500px-Deepika_Padukone_2025_%281%29.png'),
      Character(name: 'Hrithik Roshan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/92/Hrithik_Roshan_in_2024_%28cropped%29.jpg'),
      Character(name: 'Kareena Kapoor', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/29/Kareena_Kapoor_Khan_in_2023_%281%29_%28cropped%29.jpg'),
      Character(name: 'Kartik Aaryan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b1/Kartik_Aaryan_in_2025_at_23rd_Zee_Cine_Awards_2025.jpg'),
      Character(name: 'Katrina Kaif', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Katrina_Kaif_at_the_Bharat_audio_launch.jpg/500px-Katrina_Kaif_at_the_Bharat_audio_launch.jpg'),
      Character(name: 'Kiara Advani', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Kiara_Advani_snapped_at_the_screening_of_Shershaah_%28cropped%29.jpg/500px-Kiara_Advani_snapped_at_the_screening_of_Shershaah_%28cropped%29.jpg'),
      Character(name: 'Priyanka Chopra', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/45/Priyanka_Chopra_at_Bulgary_launch%2C_2024_%28cropped%29.jpg'),
      Character(name: 'Ranbir Kapoor', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Ranbir_Kapoor_snapped_at_Kalina_airport.jpg'),
      Character(name: 'Ranveer Singh', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/32/Ranveer_Singh_in_2023_%281%29_%28cropped%29.jpg'),
      Character(name: 'Salman Khan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Salman_Khan_in_2023_%281%29_%28cropped%29.jpg/500px-Salman_Khan_in_2023_%281%29_%28cropped%29.jpg'),
      Character(name: 'Shah Rukh Khan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Shah_Rukh_Khan_graces_the_launch_of_the_new_Santro.jpg'),
      Character(name: 'Shahid Kapoor', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Shahid_Kapoor_at_Bloody_Daddy_launch_%28cropped%29.jpg/500px-Shahid_Kapoor_at_Bloody_Daddy_launch_%28cropped%29.jpg'),
      Character(name: 'Shraddha Kapoor', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Shraddha_Kapoor_promoting_Street_Dancer_3D.jpg/500px-Shraddha_Kapoor_promoting_Street_Dancer_3D.jpg'),
    ];
  }

  static List<Character> getIndianCricketers() {
    return [
      Character(name: 'Anil Kumble', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/de/Anil_Kumble_%281%29.jpg'),
      Character(name: 'Hardik Pandya', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Hardik_Pandya_in_PMO_New_Delhi.jpg/500px-Hardik_Pandya_in_PMO_New_Delhi.jpg'),
      Character(name: 'Jasprit Bumrah', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Jasprit_Bumrah_in_PMO_New_Delhi.jpg/500px-Jasprit_Bumrah_in_PMO_New_Delhi.jpg'),
      Character(name: 'KL Rahul', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/69/KL_Rahul_at_Femina_Miss_India_2018_Grand_Finale_%28cropped%29.jpg'),
      Character(name: 'Kapil Dev', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/88/Kapil_Dev_at_Equation_sports_auction_%283x4_cropped%29.jpg'),
      Character(name: 'MS Dhoni', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/MS_Dhoni_%28Prabhav_%2723_-_RiGI_2023%29.jpg/500px-MS_Dhoni_%28Prabhav_%2723_-_RiGI_2023%29.jpg'),
      Character(name: 'Rahul Dravid', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Rahul_Dravid_in_2024.jpg'),
      Character(name: 'Ravichandran Ashwin', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/The_Minister_of_State_for_Youth_Affairs_and_Sports_%28Independent_Charge%29%2C_Shri_Sarbananda_Sonowal_conferring_the_Arjuna_Award_on_cricketer_Ravichandran_Ashwin%2C_in_New_Delhi_on_July_31%2C_2015_cropped.jpg/500px-thumbnail.jpg'),
      Character(name: 'Ravindra Jadeja', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2c/PM_Shri_Narendra_Modi_with_Ravindra_Jadeja_%28Cropped%29.jpg'),
      Character(name: 'Rishabh Pant', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Rishabh_Pant.jpg/500px-Rishabh_Pant.jpg'),
      Character(name: 'Rohit Sharma', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Prime_Minister_Of_Bharat_Shri_Narendra_Damodardas_Modi_with_Shri_Rohit_Gurunath_Sharma_%28Cropped%29.jpg/500px-Prime_Minister_Of_Bharat_Shri_Narendra_Damodardas_Modi_with_Shri_Rohit_Gurunath_Sharma_%28Cropped%29.jpg'),
      Character(name: 'Sachin Tendulkar', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/The_cricket_legend_Sachin_Tendulkar_at_the_Oval_Maidan_in_Mumbai_During_the_Duke_and_Duchess_of_Cambridge_Visit%2826271019082%29.jpg/500px-The_cricket_legend_Sachin_Tendulkar_at_the_Oval_Maidan_in_Mumbai_During_the_Duke_and_Duchess_of_Cambridge_Visit%2826271019082%29.jpg'),
      Character(name: 'Shikhar Dhawan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/SHIKHAR_DHAWAN_%2816005494418%29.jpg/500px-SHIKHAR_DHAWAN_%2816005494418%29.jpg'),
      Character(name: 'Sourav Ganguly', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Sourav_Ganguly_%28late_2010s%29.jpg/500px-Sourav_Ganguly_%28late_2010s%29.jpg'),
      Character(name: 'Sunil Gavaskar', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/ed/Sunny_Gavaskar_Sahara.jpg'),
      Character(name: 'VVS Laxman', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/VVS_Laxman99.jpg/500px-VVS_Laxman99.jpg'),
      Character(name: 'Virat Kohli', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Virat_Kohli_in_PMO_New_Delhi.jpg/500px-Virat_Kohli_in_PMO_New_Delhi.jpg'),
      Character(name: 'Virender Sehwag', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Virender_Sehwag_at_the_NDTV_Marks_for_Sports_event_13.jpg/500px-Virender_Sehwag_at_the_NDTV_Marks_for_Sports_event_13.jpg'),
      Character(name: 'Yuvraj Singh', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/81/Yuvraj_Singh_appointed_as_Ulysse_Nardin_watch_brand_ambassador.jpeg'),
      Character(name: 'Zaheer Khan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/27/Zaheer_Khan_at_the_CPAA_show_2018_%28cropped%29.jpg'),
    ];
  }

  static List<Character> getIndianPoliticians() {
    return [
      Character(name: 'Narendra Modi', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c0/Official_Portrait_of_Prime_Minister_Narendra_Modi_of_India.jpg'),
      Character(name: 'Amit Shah', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e0/The_Union_Minister_for_Home_Affairs%2C_Shri_Amit_Shah_Addressing_at_the_inauguration_of_the_National_Cyber_Research_and_Innovation_Centre%2C_in_New_Delhi_on_February_17%2C_2020.jpg'),
      Character(name: 'Rahul Gandhi', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c2/Rahul_Gandhi_Wayanad_2024.jpg'),
      Character(name: 'Arvind Kejriwal', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/f6/Arvind_Kejriwal_Portrait.jpg'),
      Character(name: 'Yogi Adityanath', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/90/Yogi_Adityanath_in_2022_%28cropped%29.jpg'),
      Character(name: 'Sonia Gandhi', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Sonia_Gandhi_in_2023.jpg'),
      Character(name: 'Mamata Banerjee', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a2/Mamata_Banerjee_2023.jpg'),
      Character(name: 'Rajnath Singh', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/6f/The_Union_Minister_for_Defence%2C_Shri_Rajnath_Singh_Addressing_at_the_inauguration_of_the_National_Cyber_Research_and_Innovation_Centre%2C_in_New_Delhi_on_February_17%2C_2020.jpg'),
      Character(name: 'Nitin Gadkari', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Nitin_Gadkari_in_2021_%28cropped%29.jpg'),
      Character(name: 'Smriti Irani', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/3d/Smriti_Irani_in_2023_%28cropped%29.jpg'),
      Character(name: 'Pinarayi Vijayan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/8b/Pinarayi_Vijayan_in_2022_%28cropped%29.jpg'),
      Character(name: 'MK Stalin', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/6f/M_K_Stalin_in_2022_%28cropped%29.jpg'),
      Character(name: 'Uddhav Thackeray', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/90/Uddhav_Thackeray_in_2022.jpg'),
      Character(name: 'Akhilesh Yadav', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/9f/Akhilesh_Yadav_in_2023.jpg'),
      Character(name: 'Mayawati', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Mayawati_in_2022.jpg'),
      Character(name: 'Sharad Pawar', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Sharad_Pawar_in_2022.jpg'),
    ];
  }

  static List<Character> getCharactersForTopic(String topic) {
    List<Character> chars;
    switch (topic) {
      case 'bollywood':
      case 'celebrities':
        chars = getBollywoodIcons();
        break;
      case 'cricketers':
      case 'sports':
        chars = getIndianCricketers();
        break;
      case 'politicians':
        chars = getIndianPoliticians();
        break;
      default:
        chars = getDefaultCharacters();
        break;
    }
    // Limit to 16 characters for the 4x4 3D grid
    return chars.take(16).toList();
  }
}
