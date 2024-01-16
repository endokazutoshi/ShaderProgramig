//������������������������������������������������������������������������������
 // �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D		g_texture : register(t0);	//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[

Texture2D		g_toon_texture : register(t1);

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gmodel:register(b0)
{
	float4x4	matWVP;			// ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
	float4x4	matW;           // ���[���h�s��
	float4x4	matNormal;           // ���[���h�s��
	float4		diffuseColor;		//�}�e���A���̐F���g�U���ˌW��
	float4		ambientColor;		//����
	float4		specularColor;		//���ʔ��ˁ��n�C���C�g
	float		shininess;
	bool		isTextured;			//�e�N�X�`���[���\���Ă��邩�ǂ���

};

cbuffer gmodel:register(b1)
{
	float4		lightPosition;
	float4		eyePosition;
};


//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
	float4 pos  : SV_POSITION;	//�ʒu
	float2 uv	: TEXCOORD;		//UV���W
	float4 color	: COLOR;	//�F�i���邳�j
	float4 eyev		:POSITION;
	float4 normal	:NORMAL;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
	VS_OUT outData = (VS_OUT)0;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
	pos = pos + normal * 0.5;//�h�[�i�c�̑傫����ύX���邱�Ƃ��ł���B

	outData.pos = mul(pos, matWVP);
	outData.uv = uv;
	normal.w = 0;
	normal = mul(normal, matNormal);
	normal = normalize(normal);
	outData.normal = normal;

	float4 light = normalize(lightPosition);
	light = normalize(light);

	outData.color = saturate(dot(normal, light));
	float4 posw = mul(pos, matW);
	outData.eyev = eyePosition - posw;

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);		//���C�g�F�����邳�@Iin
	float ambentSource = float4(0.2, 0.2, 0.2, 1.0);		//�A���r�G���g�W���@Ka
	float4 diffuse;
	float4 ambient;
	float4 NL = saturate(dot(inData.normal, normalize(lightPosition)));
	//float4 reflect = normalize(2 * NL * inData.normal - normalize(lightPosition));
	float4 reflection = reflect(normalize(-lightPosition), inData.normal);
	float4 specular = pow(saturate(dot(reflection, normalize(inData.eyev))), shininess) * specularColor;
	//���̕ӂŊg�U�̎Ђ̒l�����낢��Ƃ���
	float4 n1 = float4(1 / 4.0, 1 / 4.0, 1 / 4.0,1);
	float4 n2 = float4(2 / 4.0, 2 / 4.0, 2 / 4.0, 1);
	float4 n3 = float4(3 / 4.0, 3 / 4.0, 3 / 4.0, 1);
	float4 n4 = float4(4 / 4.0, 4 / 4.0, 4 / 4.0, 1);


	float2 uv;

	uv.x = inData.color.x;
	uv.y = 0;

	float4 tI = g_toon_texture.Sample(g_sampler,uv);

	/*0.1 * step(n1, inData.color) + 0.3 * step(n2, inData.color)
	+ 0.3 * step(n3, inData.color) + 0.4 * step(n4, inData.color);*/

	//if (inData.color.x < 1 / 30)
	//{
	//	nk = float4();
	//}
	//else if (inData.color.x < 2 / 3.0)
	//{
	//	nk = float4();
	//}
	//else
	//{
	//	nk = float4(1.0, 1.0, 1.0, 1.0)
	//}


	if (isTextured == 0)
	{
		diffuse = lightSource * diffuseColor * tI;
		ambient = lightSource * diffuseColor * ambientColor;
	}
	else
	{
		diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * tI;
		ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * ambientColor;
	}
	return diffuse + ambient;
	//return specular;
	//return diffuse + ambient + specular;
	//return diffuse;
	//return ambient;

	//�֊s�������x�N�g���s�ʂ̖@���̊p�x���X�O�x�t��
	/*if (dot(inData.normal, normalize(inData.eyev)) < 0.2)
		return float4(0, 0, 0, 0);
	else
		return float4(1, 1, 1, 0);*/

	//return g_texture.Sample(g_sampler, inData.uv);
}