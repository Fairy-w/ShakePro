import fitz, re
from collections import Counter, defaultdict
p=r"D:\documents\学校课程\大四上\毕设\论文定稿\Shake-Pro_论文初稿_王述珍1.0.pdf"
doc=fitz.open(p)
print('PAGES', doc.page_count)
font_sizes=[]
line_lengths=[]
issues=[]
page_texts=[]
for i,page in enumerate(doc):
    text=page.get_text('text')
    page_texts.append(text)
    d=page.get_text('dict')
    for b in d.get('blocks',[]):
        for l in b.get('lines',[]):
            spans=[]
            for s in l.get('spans',[]):
                t=s.get('text','').strip()
                if t:
                    spans.append((t,s.get('size',0),s.get('font','')))
                    font_sizes.append(round(s.get('size',0),1))
            if spans:
                line=''.join(x[0] for x in spans).strip()
                if line:
                    line_lengths.append(len(line))

# detect page number style presence
page_num_patterns=[r'^\s*[-—]?\s*\d+\s*[-—]?\s*$', r'^\s*第\s*\d+\s*页\s*共\s*\d+\s*页\s*$']
num_pages=[]
for i,t in enumerate(page_texts,1):
    lines=[x.strip() for x in t.splitlines() if x.strip()]
    tail=' '.join(lines[-3:]) if lines else ''
    hit=False
    for pat in page_num_patterns:
        if re.search(pat, tail):
            hit=True
            break
    if hit:
        num_pages.append(i)

# heading style heuristic
heading_candidates=[]
for i,t in enumerate(page_texts,1):
    for line in t.splitlines():
        s=line.strip()
        if re.match(r'^(第[一二三四五六七八九十百]+章|\d+(\.\d+){0,3})\s*\S+', s):
            heading_candidates.append((i,s))

# references formatting rough check
ref_start=None
for i,t in enumerate(page_texts,1):
    if '参考文献' in t:
        ref_start=i
        break
ref_issues=[]
if ref_start:
    ref_text='\n'.join(page_texts[ref_start-1:])
    refs=[ln.strip() for ln in ref_text.splitlines() if re.match(r'^\[\d+\]', ln.strip())]
    nums=[]
    for r in refs:
        m=re.match(r'^\[(\d+)\]',r)
        if m: nums.append(int(m.group(1)))
    if nums:
        expected=list(range(1,max(nums)+1))
        missing=sorted(set(expected)-set(nums))
        if missing:
            ref_issues.append(f'参考文献编号疑似缺失: {missing[:10]}')

print('FONT_SIZE_TOP10', Counter(font_sizes).most_common(10))
print('AVG_LINE_LEN', round(sum(line_lengths)/len(line_lengths),2) if line_lengths else 0)
print('PAGE_NUM_DETECTED_COUNT', len(num_pages))
print('PAGE_NUM_DETECTED_PAGES', num_pages[:30])
print('HEADING_SAMPLES')
for x in heading_candidates[:30]:
    print(x[0], x[1])
print('REF_START', ref_start)
for ri in ref_issues:
    print('REF_ISSUE', ri)

# print first/last lines for each page quick review
for i,t in enumerate(page_texts,1):
    lines=[ln.strip() for ln in t.splitlines() if ln.strip()]
    if not lines:
        print(f'PAGE {i} EMPTY')
        continue
    first=lines[0][:60]
    last=lines[-1][:60]
    print(f'PAGE {i} FIRST: {first}')
    print(f'PAGE {i} LAST: {last}')
