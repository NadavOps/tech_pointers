import argparse
import requests
import pprint

def get_dockerhub_tags(namespace, repository):
    api_url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags?page_size=100"
    # tags_old_way = []
    tags = {}

    while True:
        response = requests.get(api_url)
        if response.status_code == 200:
            data = response.json()
            data_results_field = data.get('results', [])

            for image in data_results_field:
                # print(image)
                tag = image.get('name', 'didnt_find_tag')
                digest = image.get('digest', 'didnt_find_digest')
                tags[tag] = { "manifest_digest": digest }
                for sub_image in image['images']:
                    architecture = sub_image.get('architecture', 'didnt_find_architecture')
                    sub_image_digest = sub_image.get('digest', 'didnt_find_architecture')
                    tags[tag][architecture] = sub_image_digest
                # print("======")

            # Extract tags from the current page
            # tags_old_way.extend(item['name'] for item in data_results_field)

            # Check if there is a next page
            next_page = data.get('next')
            if next_page:
                api_url = next_page
            else:
                break  # No more pages, exit the loop
        else:
            print(f"Error: Unable to fetch tags. Status code: {response.status_code}")
            return None

    return tags

def filter_tags_by_prefix(tags, prefix):
    filtered_tags = {}
    for tag in tags:
        if tag.startswith(prefix):
            filtered_tags[tag] = tags[tag]
    return filtered_tags

def main():
    parser = argparse.ArgumentParser(description='Retrieve and filter Docker Hub tags by prefix')
    parser.add_argument('-r', '--repository', type=str, required=True, help='Docker Hub repository')
    parser.add_argument('-n', '--namespace', type=str, default="library", help='The namespace to look at. in nadavops/tooling the namespace is nadavops')
    parser.add_argument('-t', '--tag_prefix', type=str, default=None, help='Prefix for filtering tags')
    parser.add_argument('-i', '--image_digest', type=str, default=None, help='I think this is to search for specific digest')
    parser.add_argument('-s', '--show_more_info', action='store_true', help='output more')

    args = parser.parse_args()

    tags = get_dockerhub_tags(args.namespace, args.repository)

    if args.show_more_info:
        pprint.pprint(tags)

    if tags is not None:
        if args.tag_prefix is not None:
            tags = filter_tags_by_prefix(tags, args.tag_prefix)
            print(f"\nTags filtered with the prefix '{args.tag_prefix}':")
            for tag in reversed(tags):
                if args.show_more_info:
                    pprint.pprint({tag: tags[tag]})
                else:
                    print(tag)

        if args.image_digest is not None:
            print(f"\nTags for image digest: '{args.image_digest}':")
            for tag in tags:
                for architecture in tags[tag]:
                    if tags[tag][architecture] == args.image_digest:
                        pprint.pprint({tag: {architecture: tags[tag][architecture]}})
    else:
        print("Exiting due to an error.")

if __name__ == "__main__":
    main()
