#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	github_user = "vn-input"
	github_repo = pkginfo.get("name")
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True)
	version = None
	url = None
	suffix = ['alpha', 'beta', 'rc']

	for item in json_data:
		try:
			version = item["tag_name"]
			verlist = version.split(".")
			if any(x in version for x in suffix):
				verlist.pop(-1)
			list(map(int, verlist))
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		new_ver = version.replace("-", "_")
		url = f"https://github.com/{github_user}/{github_repo}/archive/refs/tags/{version}.tar.gz"
		final_name = f"{github_repo}-{new_ver}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=new_ver,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
