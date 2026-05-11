import fitz
p=r"D:\documents\学校课程\大四上\毕设\论文定稿\Shake-Pro_论文初稿_王述珍1.0.pdf"
doc=fitz.open(p)
print('pages',doc.page_count)
for i in range(min(8,doc.page_count)):
    page=doc[i]
    text=page.get_text('text')
    print(f'---PAGE {i+1}---')
    print(text[:1500].replace('\n','\\n'))
