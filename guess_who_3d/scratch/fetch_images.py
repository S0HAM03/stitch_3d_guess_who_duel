import urllib.request
import json

titles_cricket = ['Sachin_Tendulkar', 'Virat_Kohli', 'MS_Dhoni', 'Rohit_Sharma', 'Jasprit_Bumrah', 'Ravindra_Jadeja', 'KL_Rahul', 'Hardik_Pandya', 'Yuvraj_Singh', 'Sourav_Ganguly', 'Kapil_Dev', 'Rahul_Dravid', 'VVS_Laxman', 'Anil_Kumble', 'Zaheer_Khan', 'Shikhar_Dhawan', 'Ravichandran_Ashwin', 'Sunil_Gavaskar', 'Virender_Sehwag', 'Rishabh_Pant']

titles_bollywood = ['Shah_Rukh_Khan', 'Salman_Khan', 'Aamir_Khan', 'Amitabh_Bachchan', 'Hrithik_Roshan', 'Akshay_Kumar', 'Ranbir_Kapoor', 'Ranveer_Singh', 'Deepika_Padukone', 'Priyanka_Chopra', 'Katrina_Kaif', 'Alia_Bhatt', 'Kareena_Kapoor', 'Anushka_Sharma', 'Ajay_Devgn', 'Shahid_Kapoor', 'Ayushmann_Khurrana', 'Kartik_Aaryan', 'Shraddha_Kapoor', 'Kiara_Advani']

def fetch_wiki(titles):
    url = 'https://en.wikipedia.org/w/api.php?action=query&titles=' + '|'.join(titles) + '&prop=pageimages&format=json&pithumbsize=400'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        pages = data['query']['pages']
        results = []
        for key in pages:
            page = pages[key]
            if 'thumbnail' in page:
                results.append(f"    Character(name: '{page['title']}', imageUrl: '{page['thumbnail']['source']}'),")
            else:
                results.append(f"    // NO IMAGE: {page['title']}")
        return '\n'.join(results)

print("--- CRICKETERS ---")
print(fetch_wiki(titles_cricket))
print("--- BOLLYWOOD ---")
print(fetch_wiki(titles_bollywood))
