from PIL import Image
from torchvision import transforms
import numpy as np
import math
import os
import glob
directory = "./"  # 檔案目錄路徑

# 尋找目錄中的所有PNG和JPG檔案
file_paths = glob.glob(os.path.join(directory, 'image.png')) + glob.glob(os.path.join(directory, 'image.jpg'))

images = []
print(file_paths)
for file_path in file_paths:
    try:
        img = Image.open(file_path)
        images.append(img)
    except IOError:
        # 處理無法開啟的檔案
        print(f"無法開啟檔案：{file_path}")


    
#img = Image.open('./image.png') #file path

img = img.convert('L') # convert to L (Grayscale)
resize_transform  = transforms.Resize((64, 64), interpolation=Image.BILINEAR, antialias=True)
img2 = resize_transform(img)
#img.save('out.png') #file path
#img2.save('out2.png') #file path

# img2 = Image.open('resizedImg.png') #file path

data = []
# data
pixels = img2.load()
width, height = img2.size
pixel_array = np.zeros((height, width), dtype=np.uint8)
i = 0
for y in range(height):
    for x in range(width):
        pixel_value = pixels[x, y]
        pixel_array[y, x] = pixel_value
        data.append(pixel_value)

for i in range(4096):
    data[i] = bin(data[i]*16)[2:].zfill(13)


#print(data[4095])

# layer0
def replicate_pad(arr, pad_width):
    padded_arr = np.pad(arr, pad_width, mode='edge')
    return padded_arr

# 执行复制填充
pad_width = 2  # 填充宽度
padded_arr = replicate_pad(pixel_array, pad_width)
#print(padded_arr)

# 定义Atrous卷积核
atrous_kernel = np.array([[-0.0625, -0.125, -0.0625],
                          [-0.25, 1, -0.25],
                          [-0.0625, -0.125, -0.0625]])
conv_arr = []
conv_arr2 = np.zeros((height, width), dtype=np.float32)
bias = -0.75
for i in range(64):
    for j in range(64):
        temp = 0
        temp +=padded_arr[i][j]*atrous_kernel[0][0]
        temp +=padded_arr[i][j+2]*atrous_kernel[0][1]
        temp +=padded_arr[i][j+4]*atrous_kernel[0][2]
        temp +=padded_arr[i+2][j]*atrous_kernel[1][0]
        temp +=padded_arr[i+2][j+2]*atrous_kernel[1][1]
        temp +=padded_arr[i+2][j+4]*atrous_kernel[1][2]
        temp +=padded_arr[i+4][j]*atrous_kernel[2][0]
        temp +=padded_arr[i+4][j+2]*atrous_kernel[2][1]
        temp +=padded_arr[i+4][j+4]*atrous_kernel[2][2]
        temp +=bias
        conv_arr.append(temp)
        conv_arr2[i][j] = temp


for i in range(len(conv_arr)):
    if(conv_arr[i]<0):
        conv_arr[i] = 0


for i in range(64):
    for j in range(64):
        if(conv_arr2[i][j]<0):
            conv_arr2[i][j] = 0


decimal_number = 0.625
binary_number = ''

while decimal_number != 0:
    decimal_number *= 2
    if decimal_number >= 1:
        binary_number += '1'
        decimal_number -= 1
    else:
        binary_number += '0'

layer0 = []
for i in range(4096):
    decimal_number = conv_arr[i]
    #decimal_number = 1.625
    binary_number = ''
    int_num = ''
    float_num = ''
    integer_part = int(decimal_number)  # 提取整数部分
    int_num += bin(integer_part)[2:].zfill(9)  # 将整数部分转换为二进制并添加到二进制数字符串中

    fractional_part = decimal_number - integer_part  # 提取小数部分

    while fractional_part != 0:
        fractional_part *= 2
        if fractional_part >= 1:
            float_num += '1'
            fractional_part -= 1
        else:
            float_num += '0'
    #向右補0
    float_num = float_num + '0' * (4 - len(float_num))
    #向左補0

    layer0.append(int_num + float_num)
#print(layer0[4095])
#print(conv_arr)

# layer1
maxpool_arr = []
for i in range(0,64,2):
    for j in range(0,64,2):
        if(conv_arr2[i][j]>conv_arr2[i][j+1]):
            out1 = conv_arr2[i][j]
        else:
            out1 = conv_arr2[i][j+1]
        if(conv_arr2[i+1][j]>conv_arr2[i+1][j+1]):
            out2 = conv_arr2[i+1][j]
        else:
            out2 = conv_arr2[i+1][j+1]

        if(out1>out2):
            maxpool_arr.append(math.ceil(out1))
            #maxpool_arr.append(out1)
        else:
            maxpool_arr.append(math.ceil(out2))
            #maxpool_arr.append(out2)
layer1 = []
for i in range(1024):
    layer1.append(((bin(maxpool_arr[i]*16))[2:]).zfill(13))

filename = 'img.dat'
filename0 = 'layer0_golden.dat'
filename1 = 'layer1_golden.dat'

# 逐行写入到.dat文件
with open(filename, 'w') as f:
    for item in data:
        line = str(item) + '\n'
        f.write(line)


with open(filename0, 'w') as f:
    for item in layer0:
        line = str(item) + '\n'
        f.write(line)

with open(filename1, 'w') as f:
    for item in layer1:
        line = str(item) + '\n'
        f.write(line)