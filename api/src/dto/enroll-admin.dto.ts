import { ApiProperty } from "@nestjs/swagger";
import { IsString } from "class-validator";

export class EnrollAdminDto {
    @IsString()
    @ApiProperty({
        description: 'Fabric CA Admin username',
        default: 'admin'
    })
    public name: string;

    @IsString()
    @ApiProperty({
        description: 'Fabric CA Admin password',
        default: 'adminpw'
    })
    public password: string;
}
