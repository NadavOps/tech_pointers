import argparse
import requests
import pprint

def get_dockerhub_tags(repository):
    api_url = f"https://hub.docker.com/v2/namespaces/library/repositories/{repository}/tags?page_size=100"
    tags = []

    while True:
        response = requests.get(api_url)
        if response.status_code == 200:
            data = response.json()
            data_results_field = data.get('results', [])

            # Extract tags from the current page
            tags.extend(item['name'] for item in data_results_field)

            # Check if there is a next page
            next_page = data.get('next')
            if next_page:
                api_url = next_page
            else:
                break  # No more pages, exit the loop
        else:
            print(f"Error: Unable to fetch tags. Status code: {response.status_code}")
            return None

    pprint.pprint(tags)  # Print all tags
    return tags

def filter_tags_by_prefix(tags, prefix):
    filtered_tags = [tag for tag in tags if tag.startswith(prefix)]
    return filtered_tags

def main():
    parser = argparse.ArgumentParser(description='Retrieve and filter Docker Hub tags by prefix')
    parser.add_argument('-r', '--repository', type=str, required=True, help='Docker Hub repository')
    parser.add_argument('-p', '--prefix', type=str, required=True, help='Prefix for filtering tags')

    args = parser.parse_args()

    repository = args.repository
    prefix = args.prefix

    tags = get_dockerhub_tags(repository)

    if tags is not None:
        filtered_tags = filter_tags_by_prefix(tags, prefix)

        print(f"\nTags with prefix '{prefix}':")
        for tag in reversed(filtered_tags):
            print(tag)
    else:
        print("Exiting due to an error.")

if __name__ == "__main__":
    main()
