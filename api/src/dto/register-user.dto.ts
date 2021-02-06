import { ApiProperty } from "@nestjs/swagger";

export class RegisterUserDto {
    @ApiProperty({
        description: 'Domain or username as x509 cert subject CN',
        default: 'demouser1'
    })
    name: string;

    @ApiProperty({
        description: 'user affiliation',
        default: 'org1.department1'
    })
    affiliation: string;
}
