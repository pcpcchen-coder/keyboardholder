"""Check the binary STL deliverables using only Python's standard library.

Run from any directory: python3 validation/check_stl.py
Checks edge incidence, consistent winding, one connected component,
non-degenerate triangles, positive volume, and non-negative build coordinates.
This does not test printability, self intersections, strength, or durability.
"""
import collections
import json
import math
from pathlib import Path
import struct


def check(path):
    raw = path.read_bytes()
    count = struct.unpack_from('<I', raw, 80)[0]
    assert len(raw) == 84 + count * 50, f'Invalid binary STL: {path}'
    faces = []
    vertices = {}
    coords = []
    volume6 = 0.0
    for i in range(count):
        values = struct.unpack_from('<12fH', raw, 84 + i * 50)[3:12]
        tri = [tuple(values[j:j + 3]) for j in (0, 3, 6)]
        ids = []
        for v in tri:
            assert all(math.isfinite(x) for x in v), path
            key = tuple(round(x, 5) for x in v)
            if key not in vertices:
                vertices[key] = len(coords)
                coords.append(key)
            ids.append(vertices[key])
        assert len(set(ids)) == 3, f'Degenerate triangle: {path}'
        faces.append(ids)
        a, b, c = tri
        ab = [b[j]-a[j] for j in range(3)]
        ac = [c[j]-a[j] for j in range(3)]
        cross = [ab[1]*ac[2]-ab[2]*ac[1], ab[2]*ac[0]-ab[0]*ac[2], ab[0]*ac[1]-ab[1]*ac[0]]
        assert sum(x*x for x in cross) > 1e-14, f'Zero-area triangle: {path}'
        volume6 += (a[0] * (b[1]*c[2] - b[2]*c[1])
                    + a[1] * (b[2]*c[0] - b[0]*c[2])
                    + a[2] * (b[0]*c[1] - b[1]*c[0]))
    edges = collections.Counter()
    direction = collections.Counter()
    links = collections.defaultdict(set)
    for a, b, c in faces:
        for u, v in ((a, b), (b, c), (c, a)):
            edge = tuple(sorted((u, v)))
            edges[edge] += 1
            direction[edge] += 1 if u < v else -1
            links[u].add(v)
            links[v].add(u)
    unseen = set(range(len(coords)))
    components = 0
    while unseen:
        components += 1
        stack = [unseen.pop()]
        while stack:
            for v in links[stack.pop()]:
                if v in unseen:
                    unseen.remove(v)
                    stack.append(v)
    low = [min(v[j] for v in coords) for j in range(3)]
    high = [max(v[j] for v in coords) for j in range(3)]
    report = dict(file=path.name, triangles=count,
                  watertight=all(n == 2 for n in edges.values()),
                  consistent_winding=all(n == 0 for n in direction.values()),
                  components=components, volume_mm3=round(volume6/6, 2),
                  size_mm=[round(b-a, 3) for a, b in zip(low, high)],
                  min_mm=low)
    assert report['watertight'] and report['consistent_winding'], report
    assert components == 1 and volume6 > 0 and min(low) > -0.001, report
    return report


if __name__ == '__main__':
    stl_dir = Path(__file__).resolve().parent.parent / 'STL'
    files = sorted(stl_dir.glob('*.stl'))
    assert len(files) == 10, f'Expected 10 STL files, found {len(files)}'
    print(json.dumps([check(path) for path in files], indent=2))
