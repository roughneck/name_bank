"""One-time re-bake of top names per country into data/countries/*.yml.

Stage 1 of the pipeline: writes larger mixed-script pools (curated CN/UA are
skipped). Follow with `ruby tools/split_scripts.rb` (Stage 2) to split by script.
Run once; the output YAML is committed. Requires ~3.2 GB RAM to load the dataset.
    pip install names-dataset pyyaml
    python tools/bake.py
    ruby tools/split_scripts.rb
"""
import os
import yaml
from names_dataset import NameDataset

N = 6000
CURATED = {"CN", "UA"}
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "countries")


def top_first(nd, cc, gender):
    res = nd.get_top_names(n=N, gender=gender, country_alpha2=cc)
    return res.get(cc, {}).get(gender[0].upper(), [])  # 'Male' -> 'M', 'Female' -> 'F'


def top_last(nd, cc):
    res = nd.get_top_names(n=N, use_first_names=False, country_alpha2=cc)
    val = res.get(cc, [])
    if isinstance(val, dict):  # normalize if surnames come back gender-keyed
        seen, out = set(), []
        for lst in val.values():
            for name in lst:
                if name not in seen:
                    seen.add(name)
                    out.append(name)
        return out[:N]
    return val


def main():
    nd = NameDataset()
    os.makedirs(OUT, exist_ok=True)
    for cc in nd.get_country_codes(alpha_2=True):
        if cc in CURATED:
            continue
        data = {
            "source": "dataset",
            "firstnames_male": top_first(nd, cc, "Male"),
            "firstnames_female": top_first(nd, cc, "Female"),
            "lastnames": top_last(nd, cc),
        }
        path = os.path.join(OUT, f"{cc}.yml")
        with open(path, "w", encoding="utf-8") as f:
            yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)
        print(f'{cc}: {len(data["firstnames_male"])}m/'
              f'{len(data["firstnames_female"])}f/{len(data["lastnames"])}last')


if __name__ == "__main__":
    main()
